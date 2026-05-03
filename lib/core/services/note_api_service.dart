import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/api_service.dart';

/// Role values accepted by the share endpoints.
class NoteRole {
  static const owner = 'owner';
  static const deleter = 'deleter';
  static const editor = 'editor';
  static const viewer = 'viewer';
}

class NoteShare {
  final String userId;
  final String role;
  final DateTime? createdAt;

  const NoteShare({
    required this.userId,
    required this.role,
    this.createdAt,
  });

  factory NoteShare.fromJson(Map<String, dynamic> json) => NoteShare(
        userId: (json['userId'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );
}

/// Typed service layer for the /api/NoteInfo endpoints.
class NoteApiService {
  NoteApiService._internal();
  static final NoteApiService _instance = NoteApiService._internal();
  factory NoteApiService() => _instance;

  final ApiService _api = ApiService();

  Map<String, dynamic> _userIdHeader(String userId) => {'X-User-Id': userId};

  /// GET /api/NoteInfo
  Future<List<NoteInfo>> getNotes({
    String? userId,
    String? search,
    bool? isFavorites,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'Page': page,
      'PageSize': pageSize,
    };
    if (userId != null) params['UserId'] = userId;
    if (search != null && search.isNotEmpty) params['Search'] = search;
    if (isFavorites != null) params['IsFavorites'] = isFavorites;

    final data = await _api.get('/api/NoteInfo', queryParameters: params);
    final items = (data['items'] as List<dynamic>?) ?? [];
    return items
        .map((e) => NoteInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/NoteInfo/{id}
  Future<NoteInfo> getNoteById(int id) async {
    final data = await _api.get('/api/NoteInfo/$id');
    return NoteInfo.fromJson(data as Map<String, dynamic>);
  }

  /// POST /api/NoteInfo
  ///
  /// If [userIds] is non-empty, the first element is the owner and the rest
  /// become viewers. Otherwise [userId] is used as the legacy single-owner.
  Future<NoteInfo> createNote({
    required String name,
    String? description,
    String? userId,
    List<String>? userIds,
    bool isFavorites = false,
    DateTime? reminder,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'isFavorites': isFavorites,
      if (reminder != null) 'reminder': reminder.toUtc().toIso8601String(),
    };
    if (userIds != null && userIds.isNotEmpty) {
      body['userIds'] = userIds;
    } else if (userId != null) {
      body['userId'] = userId;
    }
    final data = await _api.post('/api/NoteInfo', data: body);
    return NoteInfo.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/NoteInfo/{id}
  ///
  /// Requires [actingUserId] (X-User-Id header). The acting user must have
  /// at least edit permission. If [userIds] is provided, the request additionally
  /// requires owner role (replaces the entire share list, first element = owner).
  Future<void> updateNote({
    required int id,
    required String actingUserId,
    String? name,
    String? description,
    String? userId,
    List<String>? userIds,
    bool? isFavorites,
    DateTime? reminder,
    bool clearReminder = false,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (userId != null) body['userId'] = userId;
    if (userIds != null) body['userIds'] = userIds;
    if (isFavorites != null) body['isFavorites'] = isFavorites;
    if (clearReminder) {
      body['reminder'] = null;
    } else if (reminder != null) {
      body['reminder'] = reminder.toUtc().toIso8601String();
    }
    await _api.put(
      '/api/NoteInfo/$id',
      data: body,
      headers: _userIdHeader(actingUserId),
    );
  }

  /// DELETE /api/NoteInfo/{id} — hard-delete for everyone (owner/deleter only).
  Future<void> deleteNote(int id, {required String actingUserId}) async {
    await _api.delete(
      '/api/NoteInfo/$id',
      headers: _userIdHeader(actingUserId),
    );
  }

  /// POST /api/NoteInfo/batchCreateNotes
  Future<Map<String, dynamic>> batchCreateNotes(
      List<Map<String, dynamic>> notes) async {
    final body = {'notes': notes};
    final data =
        await _api.post('/api/NoteInfo/batchCreateNotes', data: body);
    return data as Map<String, dynamic>;
  }

  // ── Sharing & permissions ──────────────────────────────────────────────────

  /// GET /api/NoteInfo/{id}/shares — owner returned first.
  Future<List<NoteShare>> getShares(int noteId,
      {required String actingUserId}) async {
    final data = await _api.get(
      '/api/NoteInfo/$noteId/shares',
      headers: _userIdHeader(actingUserId),
    );
    final list = (data as List<dynamic>?) ?? [];
    return list
        .map((e) => NoteShare.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/NoteInfo/{id}/share — owner-only.
  /// [role] must be one of: deleter, editor, viewer.
  Future<NoteShare> shareNote({
    required int noteId,
    required String actingUserId,
    required String userId,
    required String role,
  }) async {
    final data = await _api.post(
      '/api/NoteInfo/$noteId/share',
      data: {'userId': userId, 'role': role},
      headers: _userIdHeader(actingUserId),
    );
    final json = data as Map<String, dynamic>;
    return NoteShare(
      userId: (json['userId'] ?? userId).toString(),
      role: (json['role'] ?? role).toString(),
    );
  }

  /// PUT /api/NoteInfo/{id}/share/{userId} — change a user's role (owner-only).
  Future<NoteShare> changeShareRole({
    required int noteId,
    required String actingUserId,
    required String targetUserId,
    required String role,
  }) async {
    final data = await _api.put(
      '/api/NoteInfo/$noteId/share/$targetUserId',
      data: {'role': role},
      headers: _userIdHeader(actingUserId),
    );
    final json = data as Map<String, dynamic>;
    return NoteShare(
      userId: (json['userId'] ?? targetUserId).toString(),
      role: (json['role'] ?? role).toString(),
    );
  }

  /// DELETE /api/NoteInfo/{id}/share/{userId} — revoke another user's access.
  Future<void> revokeShare({
    required int noteId,
    required String actingUserId,
    required String targetUserId,
  }) async {
    await _api.delete(
      '/api/NoteInfo/$noteId/share/$targetUserId',
      headers: _userIdHeader(actingUserId),
    );
  }

  /// DELETE /api/NoteInfo/{id}/leave — soft per-user removal.
  ///
  /// If the caller is the owner and other users exist, ownership is auto-
  /// transferred to the oldest other user. Returns the new owner id when that
  /// happens, otherwise `null`.
  Future<String?> leaveNote(int noteId,
      {required String actingUserId}) async {
    final data = await _api.delete(
      '/api/NoteInfo/$noteId/leave',
      headers: _userIdHeader(actingUserId),
    );
    if (data is Map<String, dynamic>) {
      return data['newOwnerId']?.toString();
    }
    return null;
  }

  /// POST /api/NoteInfo/{id}/transfer-owner — owner-only.
  Future<void> transferOwner({
    required int noteId,
    required String actingUserId,
    required String newOwnerId,
  }) async {
    await _api.post(
      '/api/NoteInfo/$noteId/transfer-owner',
      data: {'newOwnerId': newOwnerId},
      headers: _userIdHeader(actingUserId),
    );
  }
}
