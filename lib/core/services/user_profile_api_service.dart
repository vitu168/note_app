import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/api_service.dart';

/// Typed service layer for the /api/UserProfile endpoints.
class UserProfileApiService {
  UserProfileApiService._internal();
  static final UserProfileApiService _instance =
      UserProfileApiService._internal();
  factory UserProfileApiService() => _instance;

  final ApiService _api = ApiService();

  /// GET /api/UserProfile
  Future<List<UserProfile>> getProfiles({
    String? search,
    bool? isNote,
    int page = 1,
    int pageSize = 50,
  }) async {
    final params = <String, dynamic>{
      'Page': page,
      'PageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) params['Search'] = search;
    if (isNote != null) params['IsNote'] = isNote;

    final data =
        await _api.get('/api/UserProfile', queryParameters: params);
    final items = (data['items'] as List<dynamic>?) ?? [];
    return items
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/UserProfile/{id}
  Future<UserProfile?> getProfileById(String id) async {
    try {
      final data = await _api.get('/api/UserProfile/$id');
      return UserProfile.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GET /api/UserProfile/{id}/notes
  Future<UserProfile?> getProfileWithNotes(String id) async {
    try {
      final data = await _api.get('/api/UserProfile/$id/notes');
      return UserProfile.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// POST /api/UserProfile — create profile (called once on first login)
  Future<UserProfile> createProfile({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isNote': false,
    };
    final data = await _api.post('/api/UserProfile', data: body);
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/UserProfile/{id}
  /// Payload: { name, avatarUrl, email, isNote }
  Future<void> updateProfile({
    required String id,
    required String name,
    required String avatarUrl,
    required String email,
    required bool isNote,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'avatarUrl': avatarUrl,
      'email': email,
      'isNote': isNote,
    };
    await _api.put('/api/UserProfile/$id', data: body);
  }

  /// DELETE /api/UserProfile/{id}
  Future<void> deleteProfile(String id) async {
    await _api.delete('/api/UserProfile/$id');
  }

  /// Ensures a profile exists; creates it if not. Safe to call on login.
  Future<UserProfile> ensureProfile({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
  }) async {
    final existing = await getProfileById(id);
    if (existing != null) return existing;
    return createProfile(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
