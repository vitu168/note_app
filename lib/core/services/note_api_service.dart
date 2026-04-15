import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/api_service.dart';

/// Typed service layer for the /api/NoteInfo endpoints.
class NoteApiService {
  NoteApiService._internal();
  static final NoteApiService _instance = NoteApiService._internal();
  factory NoteApiService() => _instance;

  final ApiService _api = ApiService();

  /// GET /api/NoteInfo
  /// Returns all notes matching optional filters.
  Future<List<NoteInfo>> getNotes({
    int? userId,
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
  Future<NoteInfo> createNote({
    required String name,
    String? description,
    required int userId,
    bool isFavorites = false,
  }) async {
    final body = {
      'name': name,
      'description': description,
      'userId': userId.toString(),
      'isFavorites': isFavorites,
    };
    final data = await _api.post('/api/NoteInfo', data: body);
    return NoteInfo.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/NoteInfo/{id}
  Future<void> updateNote({
    required int id,
    String? name,
    String? description,
    required int userId,
    bool isFavorites = false,
    DateTime? createdAt,
  }) async {
    final body = {
      'name': name,
      'description': description,
      'userId': userId.toString(),
      'isFavorites': isFavorites,
      'updatedAt': DateTime.now().toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt.toIso8601String(),
    };
    await _api.put('/api/NoteInfo/$id', data: body);
  }

  /// DELETE /api/NoteInfo/{id}
  Future<void> deleteNote(int id) async {
    await _api.delete('/api/NoteInfo/$id');
  }

  /// POST /api/NoteInfo/batchCreateNotes
  Future<Map<String, dynamic>> batchCreateNotes(
      List<Map<String, dynamic>> notes) async {
    final body = {'notes': notes};
    final data =
        await _api.post('/api/NoteInfo/batchCreateNotes', data: body);
    return data as Map<String, dynamic>;
  }
}
