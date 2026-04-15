import 'package:flutter/material.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';

class ChatPageProvider extends ChangeNotifier {
  final UserProfileApiService _api = UserProfileApiService();

  List<UserProfile> _users = [];
  List<UserProfile> _filtered = [];
  bool _loading = false;
  String _searchQuery = '';

  List<UserProfile> get users => _filtered;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await _api.getProfiles(pageSize: 100);
      _applyFilter();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => loadUsers();

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = List.of(_users);
    } else {
      _filtered = _users.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }
  }
}
