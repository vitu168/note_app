import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_repository.dart';

class HomePageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();

  List<NoteInfo> _notes = [];
  bool _loading = false;
  bool _isGrid = true;
  String _search = '';
  String _sortOption = 'date';
  bool _favoritesOnly = false;

  List<NoteInfo> get notes => _notes;
  bool get loading => _loading;
  bool get isGrid => _isGrid;
  String get search => _search;
  String get sortOption => _sortOption;
  bool get favoritesOnly => _favoritesOnly;

  Future<void> loadNotes({String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      _notes = await _repo.getNotes(
        search: search,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => loadNotes(search: _search.trim().isEmpty ? null : _search.trim());

  void setGridView(bool v) {
    if (_isGrid == v) return;
    _isGrid = v;
    notifyListeners();
  }

  void setFavoritesOnly(bool v) {
    if (_favoritesOnly == v) return;
    _favoritesOnly = v;
    notifyListeners();
  }

  void setSort(String option) {
    _sortOption = option;
    switch (_sortOption) {
      case 'title':
        _notes.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
        break;
      case 'favorites':
        _notes.sort((a, b) => (_repo.isFavorite(b.id) ? 1 : 0).compareTo(_repo.isFavorite(a.id) ? 1 : 0));
        break;
      case 'date':
      default:
        _notes.sort((a, b) => b.updatedAt?.compareTo(a.updatedAt ?? DateTime.now()) ?? 0);
        break;
    }
    notifyListeners();
  }

  void setSearch(String q) {
    _search = q;
    loadNotes(search: q.trim().isEmpty ? null : q.trim());
  }

  List<NoteInfo> get filteredNotes {
    return _notes.where((n) {
      if (_repo.isArchived(n.id)) return false;
      if (_favoritesOnly && !n.isFavorites) return false;
      return true;
    }).toList();
  }

  Future<NoteInfo> addNote(String name, String? description) async {
    final note = await _repo.addNote(name: name, description: description);
    _notes.insert(0, note);
    notifyListeners();
    return note;
  }

  Future<NoteInfo> updateNote(NoteInfo note) async {
    final updated = await _repo.updateNote(note);
    final idx = _notes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) _notes[idx] = updated;
    notifyListeners();
    return updated;
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    await _repo.toggleFavorite(id);
    notifyListeners();
  }

  Future<void> toggleArchive(int id) async {
    await _repo.toggleArchive(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
