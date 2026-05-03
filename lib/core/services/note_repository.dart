import 'package:note_app/core/data/services/custom_auth_service.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_api_service.dart';
import 'package:note_app/core/services/reminder_notification_service.dart';
class NoteRepository {
  NoteRepository._internal();
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;

  final NoteApiService _api = NoteApiService();
  final Set<int> _archived = {};
  List<NoteInfo> _cache = [];

  static Future<String> _getEffectiveUserId() async {
    final user = await CustomAuthService.getCurrentUser();
    if (user == null) throw StateError('No authenticated user found.');
    return user.userId;
  }

  Future<List<NoteInfo>> getNotes({
    bool includeArchived = false,
    String? search,
    bool? isFavorites,
    int page = 1,
    int pageSize = 20,
  }) async {
    final uid = await _getEffectiveUserId();
    final all = await _api.getNotes(
      userId: uid,
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
    String? userId,
    List<String>? userIds,
    bool isFavorites = false,
    DateTime? reminder,
  }) async {
    final uid = userId ?? await _getEffectiveUserId();
    final note = await _api.createNote(
      name: name,
      description: description,
      userId: uid,
      userIds: userIds,
      isFavorites: isFavorites,
      reminder: reminder,
    );
    _cache.insert(0, note);
    await ReminderNotificationService.instance.scheduleForNote(note);
    return note;
  }

  Future<NoteInfo> updateNote(NoteInfo note) async {
    final acting = await _getEffectiveUserId();
    await _api.updateNote(
      id: note.id,
      actingUserId: acting,
      name: note.name,
      description: note.description,
      isFavorites: note.isFavorites,
      reminder: note.reminder,
      clearReminder: note.reminder == null,
    );
    final idx = _cache.indexWhere((n) => n.id == note.id);
    if (idx != -1) _cache[idx] = note;
    await ReminderNotificationService.instance.scheduleForNote(note);
    return note;
  }

  Future<void> deleteNote(int id) async {
    final acting = await _getEffectiveUserId();
    await _api.deleteNote(id, actingUserId: acting);
    _cache.removeWhere((n) => n.id == id);
    _archived.remove(id);
    await ReminderNotificationService.instance.cancelForNote(id);
  }

  Future<void> toggleFavorite(int id) async {
    final idx = _cache.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final note = _cache[idx];
    final flipped = note.copyWith(isFavorites: !note.isFavorites);
    final acting = await _getEffectiveUserId();
    await _api.updateNote(
      id: id,
      actingUserId: acting,
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
  Future<List<NoteShare>> getShares(int noteId) async {
    final acting = await _getEffectiveUserId();
    return _api.getShares(noteId, actingUserId: acting);
  }

  Future<NoteShare> shareNote({
    required int noteId,
    required String userId,
    required String role,
  }) async {
    final acting = await _getEffectiveUserId();
    return _api.shareNote(
      noteId: noteId,
      actingUserId: acting,
      userId: userId,
      role: role,
    );
  }

  Future<NoteShare> changeShareRole({
    required int noteId,
    required String targetUserId,
    required String role,
  }) async {
    final acting = await _getEffectiveUserId();
    return _api.changeShareRole(
      noteId: noteId,
      actingUserId: acting,
      targetUserId: targetUserId,
      role: role,
    );
  }

  Future<void> revokeShare({
    required int noteId,
    required String targetUserId,
  }) async {
    final acting = await _getEffectiveUserId();
    await _api.revokeShare(
      noteId: noteId,
      actingUserId: acting,
      targetUserId: targetUserId,
    );
  }

  Future<String?> leaveNote(int noteId) async {
    final acting = await _getEffectiveUserId();
    final newOwner = await _api.leaveNote(noteId, actingUserId: acting);
    _cache.removeWhere((n) => n.id == noteId);
    _archived.remove(noteId);
    return newOwner;
  }

  Future<void> transferOwner({
    required int noteId,
    required String newOwnerId,
  }) async {
    final acting = await _getEffectiveUserId();
    await _api.transferOwner(
      noteId: noteId,
      actingUserId: acting,
      newOwnerId: newOwnerId,
    );
  }
}
