import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';

class NoteCard extends StatelessWidget {
  final NoteInfo note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({super.key, required this.note, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.name ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              note.description ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Edit',
                  onPressed: () {
                    if (onEdit != null) {
                      onEdit!();
                    } else {
                      showToast(context, 'Edit functionality coming soon!');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  tooltip: 'Delete',
                  onPressed: () {
                    if (onDelete != null) {
                      onDelete!();
                    } else {
                      showToast(context, 'Delete functionality coming soon!');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
