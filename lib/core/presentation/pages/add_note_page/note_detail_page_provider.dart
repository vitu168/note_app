import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/note_repository.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';

class NoteDetailPageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();
  final UserProfileApiService _userApiService = UserProfileApiService();

  bool _loading = false;
  bool get loading => _loading;

  List<UserProfile> _availableUsers = [];
  List<UserProfile> get availableUsers => _availableUsers;

  List<String> _selectedUserIds = [];
  List<String> get selectedUserIds => _selectedUserIds;

  Future<void> loadAvailableUsers({String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      _availableUsers = await _userApiService.getProfiles(
        search: search,
        pageSize: 100,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void addSelectedUser(String userId) {
    if (!_selectedUserIds.contains(userId)) {
      _selectedUserIds.add(userId);
      notifyListeners();
    }
  }

  void removeSelectedUser(String userId) {
    _selectedUserIds.remove(userId);
    notifyListeners();
  }

  void clearSelectedUsers() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  Future<NoteInfo> createNote({
    required String name,
    String? description,
    bool isFavorites = false,
    DateTime? reminder,
    List<String>? shareWithUserIds,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final n = await _repo.addNote(
        name: name,
        description: description,
        isFavorites: isFavorites,
        reminder: reminder,
        userIds: shareWithUserIds,
      );
      return n;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<NoteInfo> updateNote(NoteInfo note) async {
    _loading = true;
    notifyListeners();
    try {
      final updated = await _repo.updateNote(note);
      return updated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
