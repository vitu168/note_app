import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart';
import 'note_card.dart';

class NoteSearchDelegate extends SearchDelegate {
  final List<NoteInfo> notes;
  NoteSearchDelegate(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = notes
        .where((n) =>
            (n.name ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (n.description ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
      children: results.map((n) => NoteCard(note: n)).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
