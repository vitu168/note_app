import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_api_service.dart';

/// Notes repository backed by the remote REST API.
/// Archive state is kept local (in-memory) since the backend has no archive concept.
class NoteRepository {
  NoteRepository._internal();
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;

  final NoteApiService _api = NoteApiService();
  final Set<int> _archived = {};
  List<NoteInfo> _cache = [];

  static const int _userId = 5;

  Future<List<NoteInfo>> getNotes({
    bool includeArchived = false,
    String? search,
    bool? isFavorites,
    int page = 1,
    int pageSize = 20,
  }) async {
    final all = await _api.getNotes(
      userId: _userId,
      search: search,
      isFavorites: isFavorites,
      page: page,
      pageSize: pageSize,
    );
    _cache = List.of(all);
    if (includeArchived) return List.unmodifiable(_cache);
    return List.unmodifiable(
        _cache.where((n) => !_archived.contains(n.id)));
  }

  Future<List<NoteInfo>> getFavorites() async {
    return getNotes(isFavorites: true);
  }

  Future<List<NoteInfo>> getArchived() async {
    return List.unmodifiable(
        _cache.where((n) => _archived.contains(n.id)));
  }

  Future<NoteInfo> addNote({
    required String name,
    String? description,
    int? userId,
    bool isFavorites = false,
  }) async {
    final uid = userId ?? _userId;
    final note = await _api.createNote(
      name: name,
      description: description,
      userId: uid,
      isFavorites: isFavorites,
    );
    _cache.insert(0, note);
    return note;
  }

  Future<NoteInfo> updateNote(NoteInfo note) async {
    await _api.updateNote(
      id: note.id,
      name: note.name,
      description: note.description,
      userId: int.tryParse(note.userId ?? '') ?? _userId,
      isFavorites: note.isFavorites,
    );
    final idx = _cache.indexWhere((n) => n.id == note.id);
    if (idx != -1) _cache[idx] = note;
    return note;
  }

  Future<void> deleteNote(int id) async {
    await _api.deleteNote(id);
    _cache.removeWhere((n) => n.id == id);
    _archived.remove(id);
  }

  Future<void> toggleFavorite(int id) async {
    final idx = _cache.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final note = _cache[idx];
    final flipped = note.copyWith(isFavorites: !note.isFavorites);
    await _api.updateNote(
      id: id,
      name: note.name,
      description: note.description,
      userId: int.tryParse(note.userId ?? '') ?? _userId,
      isFavorites: flipped.isFavorites,
    );
    _cache[idx] = flipped;
  }

  Future<void> toggleArchive(int id) async {
    if (_archived.contains(id)) {
      _archived.remove(id);
    } else {
      _archived.add(id);
    }
  }

  bool isFavorite(int id) {
    final note = _cache.firstWhere((n) => n.id == id,
        orElse: () => const NoteInfo(id: -1));
    return note.isFavorites;
  }

  bool isArchived(int id) => _archived.contains(id);
}

