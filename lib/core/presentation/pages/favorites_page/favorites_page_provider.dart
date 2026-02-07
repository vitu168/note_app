import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_repository.dart';

class FavoritesPageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();
  List<NoteInfo> _favorites = [];
  bool _loading = false;

  List<NoteInfo> get favorites => _favorites;
  bool get loading => _loading;

  Future<void> loadFavorites() async {
    _loading = true;
    notifyListeners();
    try {
      _favorites = await _repo.getFavorites();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int id) async {
    await _repo.toggleFavorite(id);
    await loadFavorites();
  }
}
