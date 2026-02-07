import 'dart:async';

import 'package:note_app/core/models/note_info.dart';

/// A simple in-memory notes repository used by providers.
/// Replace with remote DB (Supabase, SQLite, etc.) when available.
class NoteRepository {
  NoteRepository._internal() {
    _seed();
  }

  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;

  final List<NoteInfo> _notes = [];
  final Set<int> _favorites = {};
  final Set<int> _archived = {};
  int _nextId = 100;

  void _seed() {
    final now = DateTime.now();
    _notes.addAll([
      NoteInfo(id: 1, name: 'Welcome to Notes!', description: 'This is your first note.', createdAt: now, updatedAt: now, userId: 'user1'),
      NoteInfo(id: 2, name: 'Project Meeting', description: 'Discuss milestones.', createdAt: now.subtract(const Duration(days: 1)), updatedAt: now.subtract(const Duration(days: 1)), userId: 'user1'),
      NoteInfo(id: 3, name: 'Grocery List', description: 'Milk, eggs, bread.', createdAt: now.subtract(const Duration(hours: 5)), updatedAt: now.subtract(const Duration(hours: 5)), userId: 'user1'),
    ]);
    _nextId = 4;
  }

  Future<List<NoteInfo>> getNotes({bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (includeArchived) return List.unmodifiable(_notes);
    return List.unmodifiable(_notes.where((n) => !_archived.contains(n.id)));
  }

  Future<List<NoteInfo>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final favs = _notes.where((n) => _favorites.contains(n.id) && !_archived.contains(n.id)).toList();
    return List.unmodifiable(favs);
  }

  Future<List<NoteInfo>> getArchived() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final archived = _notes.where((n) => _archived.contains(n.id)).toList();
    return List.unmodifiable(archived);
  }

  Future<NoteInfo> addNote({required String name, String? description, String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final note = NoteInfo(id: _nextId++, name: name, description: description, createdAt: DateTime.now(), updatedAt: DateTime.now(), userId: userId);
    _notes.insert(0, note);
    return note;
  }

  Future<NoteInfo> updateNote(NoteInfo note) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw Exception('Note not found');
    final updated = NoteInfo(
      id: note.id,
      name: note.name,
      description: note.description,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
      userId: note.userId,
    );
    _notes[index] = updated;
    return updated;
  }

  Future<void> deleteNote(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _notes.removeWhere((n) => n.id == id);
    _favorites.remove(id);
    _archived.remove(id);
  }

  Future<void> toggleFavorite(int id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (_favorites.contains(id)) _favorites.remove(id);
    else _favorites.add(id);
  }

  Future<void> toggleArchive(int id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (_archived.contains(id)) _archived.remove(id);
    else _archived.add(id);
  }

  bool isFavorite(int id) => _favorites.contains(id);
  bool isArchived(int id) => _archived.contains(id);
}
