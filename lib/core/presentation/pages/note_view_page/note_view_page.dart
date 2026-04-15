import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/components/app_page_header.dart';
import 'package:note_app/core/presentation/pages/add_note_page/add_note_page.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
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
      context.read<HomePageProvider>().loadNotes();
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = ctx.appTheme;
        return AlertDialog(
          backgroundColor: t.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Note',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: t.titleText,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${_note.name}"? This cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 14, color: t.bodyText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.poppins(color: t.hintText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: t.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<HomePageProvider>().deleteNote(_note.id);
      if (context.mounted) {
        await context.read<HomePageProvider>().loadNotes();
        showToast(context, 'Note deleted', type: ToastType.success);
        if (context.mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final dateFmt = DateFormat('MMM d, yyyy · h:mm a');
    final createdStr =
        _note.createdAt != null ? dateFmt.format(_note.createdAt!) : null;
    final updatedStr =
        _note.updatedAt != null ? dateFmt.format(_note.updatedAt!) : null;

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      appBar: AppPageHeader(
        title: 'Note Detail',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _note.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: t.titleText,
                      height: 1.3,
                    ),
                  ),
                ),
                if (_note.isFavorites) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: t.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: t.primary, size: 18),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // ── Date metadata ───────────────────────────────────
            if (createdStr != null)
              _DateChip(icon: Icons.calendar_today_outlined, label: createdStr),
            if (updatedStr != null && updatedStr != createdStr) ...[
              const SizedBox(height: 4),
              _DateChip(icon: Icons.update_rounded, label: 'Edited $updatedStr'),
            ],

            const SizedBox(height: 24),
            Divider(height: 1, color: t.divider.withValues(alpha: 0.5)),
            const SizedBox(height: 24),

            // ── Content ─────────────────────────────────────────
            Text(
              _note.description ?? '',
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.7,
                color: t.bodyText,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _openEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.primary.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: t.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: t.hintText),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: t.hintText,
          ),
        ),
      ],
    );
  }
}
