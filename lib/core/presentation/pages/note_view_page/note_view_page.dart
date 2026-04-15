import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/pages/add_note_page/add_note_page.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/l10n/app_localizations.dart';

class NoteViewPage extends StatefulWidget {
  final NoteInfo note;

  const NoteViewPage({super.key, required this.note});

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  late NoteInfo _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  Future<void> _openEdit() async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddNotePage(existingNote: _note)),
    );
    if (refreshed == true && context.mounted) {
      // Refresh list behind us and pop back with true
      context.read<HomePageProvider>().loadNotes();
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${_note.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<HomePageProvider>().deleteNote(_note.id);

      if (context.mounted) {
        // Refresh list to show updated data
        await context.read<HomePageProvider>().loadNotes();
        showToast(context, 'Note deleted successfully', type: ToastType.success);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Error deleting note: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMMM d, yyyy · h:mm a');
    final createdStr = _note.createdAt != null
        ? dateFormatter.format(_note.createdAt!)
        : '';
    final updatedStr = _note.updatedAt != null
        ? dateFormatter.format(_note.updatedAt!)
        : '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          'Note Detail',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _note.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_note.isFavorites)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Metadata row
            if (createdStr.isNotEmpty)
              _MetaRow(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: createdStr,
                theme: theme,
              ),
            if (updatedStr.isNotEmpty)
              _MetaRow(
                icon: Icons.update_rounded,
                label: 'Updated',
                value: updatedStr,
                theme: theme,
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 20),

            // Content
            Text(
              _note.description ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.7,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),

            const SizedBox(height: 32),

            // Note info chip row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.tag_rounded,
                  label: 'ID: ${_note.id}',
                  theme: theme,
                ),
                if (_note.isFavorites)
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: 'Favorite',
                    theme: theme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
