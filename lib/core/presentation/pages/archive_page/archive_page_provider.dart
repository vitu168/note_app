import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_repository.dart';

class ArchivePageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();
  List<NoteInfo> _archived = [];
  bool _loading = false;

  List<NoteInfo> get archived => _archived;
  bool get loading => _loading;

  Future<void> loadArchived() async {
    _loading = true;
    notifyListeners();
    try {
      _archived = await _repo.getArchived();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> restore(int id) async {
    await _repo.toggleArchive(id);
    await loadArchived();
  }

  Future<void> deletePermanent(int id) async {
    await _repo.deleteNote(id);
    await loadArchived();
  }
}
