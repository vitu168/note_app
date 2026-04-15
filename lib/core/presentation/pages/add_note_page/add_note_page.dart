import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/presentation/components/app_page_header.dart';
import 'package:note_app/core/presentation/components/app_text_field.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/pages/add_note_page/note_detail_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
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
  TimeOfDay? _reminderTime;
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

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
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
    final t = context.appTheme;
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<UserProfileProvider>().profile;
    final userName = profile?.name ?? profile?.email ?? l10n.profileName;
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final avatarUrl = profile?.avatarUrl ?? '';

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      appBar: AppPageHeader(
        title: _isEditing ? l10n.editNote : l10n.addNote,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarUrl.isNotEmpty
                          ? Colors.transparent
                          : t.primary.withValues(alpha: 0.12),
                    ),
                    child: ClipOval(
                      child: avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: t.primary.withValues(alpha: 0.12),
                                child: Center(
                                  child: Text(
                                    userInitial,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: t.primary,
                                    ),
                                  ),
                                ),
                              ),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                          color: t.primary.withValues(alpha: 0.12),
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        t.primary),
                                              ),
                                            ),
                                          ),
                                        ),
                            )
                          : Center(
                              child: Text(
                                userInitial,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: t.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.titleText,
                        ),
                      ),
                      Text(
                        'Note Author',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: t.hintText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Title field ──────────────────────────────────────────────────
              AppTextField(
                controller: _titleController,
                hint: l10n.titleHint,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: t.titleText,
                lineHeight: 1.3,
                maxLines: null,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: t.divider.withValues(alpha: 0.4)),
              const SizedBox(height: 16),

              // ── Content field ────────────────────────────────────────────────
              AppTextField(
                controller: _contentController,
                hint: l10n.contentHint,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: t.bodyText,
                lineHeight: 1.7,
                maxLines: null,
                minLines: 14,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 36),
              Divider(height: 1, color: t.divider.withValues(alpha: 0.4)),
              const SizedBox(height: 20),

              // ── Options card ─────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Favorite toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 20,
                            color: _isFavorite ? t.primary : t.hintText,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mark as Favorite',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: t.titleText,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: _isFavorite,
                            activeColor: t.primary,
                            onChanged: (v) => setState(() => _isFavorite = v),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: t.divider.withValues(alpha: 0.4),
                    ),
                    InkWell(
                      onTap: _selectReminderTime,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: _reminderTime != null
                                  ? t.primary
                                  : t.hintText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Reminder',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: t.titleText,
                                ),
                              ),
                            ),
                            if (_reminderTime != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: t.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _reminderTime!.format(context),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: t.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _reminderTime = null),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: t.hintText,
                                ),
                              ),
                            ] else
                              Text(
                                'Set time',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: t.hintText,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: t.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.save,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
