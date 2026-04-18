import 'package:flutter/material.dart';
import 'package:note_app/core/data/services/custom_auth_service.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';

/// Manages the current user's profile in the backend.
/// Call [syncOnLogin] right after the user authenticates (or on app start for guests).
class UserProfileProvider extends ChangeNotifier {
  final UserProfileApiService _service = UserProfileApiService();

  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  /// Returns the authenticated user's ID.
  /// Throws [StateError] if no user is currently signed in.
  static Future<String> _getEffectiveUserId() async {
    final user = await CustomAuthService.getCurrentUser();
    if (user == null) throw StateError('No authenticated user found.');
    return user.userId;
  }

  /// Loads the current user's profile. Creates a new profile if none exists yet.
  Future<void> syncOnLogin() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await CustomAuthService.getCurrentUser();
      if (user == null) throw StateError('No authenticated user found.');
      _profile = await _service.ensureProfile(
        id: user.userId,
        email: user.email,
        name: user.name,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Reload the current user profile from the backend.
  Future<void> reload() async {
    _loading = true;
    notifyListeners();

    try {
      final user = await CustomAuthService.getCurrentUser();
      if (user == null) throw StateError('No authenticated user found.');
      _profile = await _service.ensureProfile(
        id: user.userId,
        email: user.email,
        name: user.name,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update the profile on the backend and refresh local state.
  Future<void> updateProfile({
    required String name,
    required String avatarUrl,
    required String email,
  }) async {
    if (_profile == null) return;

    _loading = true;
    notifyListeners();

    try {
      final uid = await _getEffectiveUserId();
      final isNote = _profile!.isNote ?? false;
      await _service.updateProfile(
        id: uid,
        name: name,
        avatarUrl: avatarUrl,
        email: email,
        isNote: isNote,
      );
      _profile = _profile!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
        email: email,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
