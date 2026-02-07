import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/note_repository.dart';

class NoteDetailPageProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();

  bool _loading = false;
  bool get loading => _loading;

  Future<NoteInfo> createNote({required String name, String? description}) async {
    _loading = true;
    notifyListeners();
    try {
      final n = await _repo.addNote(name: name, description: description);
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
