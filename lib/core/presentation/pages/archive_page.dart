import 'package:flutter/material.dart';
import 'package:note_app/core/models/note_info.dart'; // <-- use this import
import 'package:note_app/core/presentation/widgets/note_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  // Sample static notes (update to match NoteInfo fields)
  final List<NoteInfo> notes = [
    NoteInfo(
      id: 2,
      name: 'Archived Note',
      description: 'This is an archived note.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 'user1',
    ),
    // Add more sample notes if needed
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredNotes = notes
        .where((n) =>
            (n.name ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (n.description ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.archive_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Archive',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: theme.colorScheme.primary,
            ),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search archive...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(Icons.clear, color: theme.colorScheme.primary),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.13),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            // Notes list/grid or empty state
            Expanded(
              child: filteredNotes.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.archive_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No archived notes',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    )
                  : _isGridView
                      ? GridView.builder(
                          itemCount: filteredNotes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (context, i) =>
                              NoteCard(note: filteredNotes[i]),
                        )
                      : ListView.separated(
                          itemCount: filteredNotes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              NoteCard(note: filteredNotes[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
