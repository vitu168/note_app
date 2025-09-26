
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/model/model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final SupabaseClient _client = Supabase.instance.client;

  DatabaseHelper._init();

  Future<List<Model>> readAllNotes() async {
    try {
      final response =
          await _client.from('note').select().order('date', ascending: false);
      return (response as List<dynamic>)
          .map((json) => Model.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<List<Model>> readFavoriteNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('isFavourite', true)
          .order('date', ascending: false);
      return (response as List<dynamic>)
          .map((json) => Model.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite notes: $e');
    }
  }

  Future<Model> create(Model note) async {
    try {
      final response =
          await _client.from('notes').insert(note.toMap()).select().single();
      return Model.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create note:$e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.from('notes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
