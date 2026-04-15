import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/pages/add_note_page/note_detail_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class AddNotePage extends StatefulWidget {
  final NoteInfo? existingNote;
  const AddNotePage({super.key, this.existingNote});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isFavorite = false;
  bool _saving = false;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    if (note != null) {
      _titleController.text = note.name ?? '';
      _contentController.text = note.description ?? '';
      _isFavorite = note.isFavorites;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showToast(context, AppLocalizations.of(context).titleRequired,
          type: ToastType.error);
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<NoteDetailPageProvider>();

    try {
      if (_isEditing) {
        await provider.updateNote(
          widget.existingNote!.copyWith(
            name: title,
            description: _contentController.text.trim(),
            isFavorites: _isFavorite,
          ),
        );
      } else {
        await provider.createNote(
          name: title,
          description: _contentController.text.trim(),
          isFavorites: _isFavorite,
        );
      }
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).noteSaved,
            type: ToastType.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<UserProfileProvider>().profile;

    final userName = profile?.name ?? profile?.email ?? l10n.profileName;
    final userInitial =
        userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? l10n.editNote : l10n.addNote,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: Text(
                    l10n.save,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          // ── Author row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    userInitial,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    userName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.12)),

          // ── Scrollable content ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: l10n.titleHint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.25),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                  ),

                  const SizedBox(height: 16),

                  // Content
                  TextField(
                    controller: _contentController,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.7,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: l10n.contentHint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.7,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.25),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    minLines: 8,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom toolbar ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: _isFavorite
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.markFavorite,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _isFavorite,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _isFavorite = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

