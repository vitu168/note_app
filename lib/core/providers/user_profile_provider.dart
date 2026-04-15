import 'package:flutter/material.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';

/// Manages the current user's profile in the backend.
/// Call [syncOnLogin] right after the user authenticates.
class UserProfileProvider extends ChangeNotifier {
  final UserProfileApiService _service = UserProfileApiService();

  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  static const String _kFixedUserId = '5';

  /// Loads the fixed user profile (ID = 5) from the backend.
  Future<void> syncOnLogin() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfileById(_kFixedUserId);
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
      _profile = await _service.getProfileById(_kFixedUserId);
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
      final isNote = _profile!.isNote ?? false;
      await _service.updateProfile(
        id: _kFixedUserId,
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
