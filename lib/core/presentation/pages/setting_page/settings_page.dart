import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/services/storage_service.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:provider/provider.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/presentation/auth/welcome_page.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';

// ─── Accent color presets shown in the Appearance card ────────────────────────
const _kPresets = <Color>[
  Color(0xFF5C6BC0), // Indigo
  Color(0xFF1E88E5), // Blue
  Color(0xFF00897B), // Teal
  Color(0xFF388E3C), // Green
  Color(0xFFAFB800), // Lime
  Color(0xFFF57C00), // Orange
  Color(0xFFE53935), // Red
  Color(0xFF8E24AA), // Purple
  Color(0xFF795548), // Brown
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = context.watch<HelperProvider>();
    final t = context.appTheme;
    final strings = AppLocalizations.of(context);
    Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            children: [
              // ── User Profile Card ─────────────────────────────
              _UserProfileCard(),
              const SizedBox(height: 12),

              // ── Appearance ────────────────────────────────────
              _SectionLabel(label: 'Appearance'),
              const SizedBox(height: 12),
              _AppearanceCard(helper: helper),
              const SizedBox(height: 12),

              // ── Logout ────────────────────────────────────────
              _SectionLabel(label: 'Account'),
              const SizedBox(height: 12),
              _SettingsGroup(children: [
                _SettingRow(
                  icon: Icons.logout_rounded,
                  iconBg: t.iconRed,
                  title: strings.logout,
                  subtitle: strings.logoutDesc,
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, strings),
                ),
              ]),
              const SizedBox(height: 40),

              // ── Footer ────────────────────────────────────────
              _VersionFooter(strings: strings),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, AppLocalizations strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.logoutQ),
        content: Text(strings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: context.appTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await AuthService.signOut()
                    .timeout(const Duration(seconds: 5));
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (r) => false,
                );
                showToast(context, '${strings.logout} successful');
              } on TimeoutException {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (r) => false,
                );
                showToast(
                  context,
                  'Sign out timed out — signed out locally.',
                );
                unawaited(AuthService.signOut().catchError((_) {}));
              } catch (e) {
                Navigator.pop(context);
                showToast(context, 'Logout failed: $e');
              }
            },
            child: Text(strings.logout),
          ),
        ],
      ),
    );
  }
}

// ─── Edit profile sheet launcher ─────────────────────────────────────────────

void _showEditProfileSheet(BuildContext context) {
  final profile = context.read<UserProfileProvider>().profile;
  if (profile == null) return;
  final user = AuthService.currentUser();
  final email = user?.email ?? profile.email ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(profile: profile, initialEmail: email),
  );
}

// ─── User Profile Card ─────────────────────────────────────────────────────────

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser();
    final profile = context.watch<UserProfileProvider>().profile;
    final helper = context.watch<HelperProvider>();
    final t = context.appTheme;

    final name = profile?.name ?? user?.email ?? 'User';
    final email = user?.email ?? '';
    final avatarUrl = profile?.avatarUrl;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final accent = helper.primaryColor;

    return Column(
      children: [
        const SizedBox(height: 38),
        const SizedBox(height: 20),
        // Larger avatar with stacked active badge and clean edit overlay
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _avatarFallback(t, initial),
                      )
                    : _avatarFallback(t, initial),
              ),
            ),
            Positioned(
              bottom: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _showEditProfileSheet(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: t.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.divider.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: accent,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Name
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: t.titleText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        // Email
        Text(
          email,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: t.hintText,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _avatarFallback(dynamic t, String initial) {
    return Container(
      color: t.primaryMuted,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: t.primary,
          ),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  final String initialEmail;

  const _EditProfileSheet({
    required this.profile,
    required this.initialEmail,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;
  bool _uploadingImage = false;
  // null = keep existing, '' = cleared, non-empty = new URL
  String? _pendingAvatarUrl;

  String get _currentAvatarUrl =>
      _pendingAvatarUrl ?? widget.profile.avatarUrl ?? '';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name ?? '');
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingImage = true);
    try {
      final file = File(picked.path);
      final userId = widget.profile.id;
      final url = await StorageService().uploadAvatar(
        imageFile: file,
        userId: userId,
      );
      if (mounted) setState(() => _pendingAvatarUrl = url);
    } catch (e) {
      if (mounted) {
        // Show the real error so it's easier to diagnose
        final msg = e.toString().replaceFirst('Exception: ', '');
        showToast(context, 'Upload failed: $msg');
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final t = context.appTheme;
        return Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: t.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: t.titleText,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ImageSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      showToast(context, 'Name cannot be empty');
      return;
    }
    if (email.isEmpty) {
      showToast(context, 'Email cannot be empty');
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<UserProfileProvider>().updateProfile(
            name: name,
            avatarUrl: _currentAvatarUrl,
            email: email,
          );
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'Profile updated', type: ToastType.success);
      }
    } catch (_) {
      if (mounted) {
        showToast(context, 'Failed to update profile');
        setState(() => _saving = false);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '?';
    final initial = name[0].toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: t.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // ── Avatar picker ─────────────────────────────────
          GestureDetector(
            onTap: _uploadingImage ? null : _showImageSourceSheet,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatar circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: t.primary.withValues(alpha: 0.30),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _uploadingImage
                        ? Container(
                            color: t.primaryMuted,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(t.primary),
                              ),
                            ),
                          )
                        : _currentAvatarUrl.isNotEmpty
                            ? Image.network(
                                _currentAvatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarFallback(t, initial),
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : _avatarFallback(t, initial),
                              )
                            : _avatarFallback(t, initial),
                  ),
                ),
                // Camera badge overlay
                if (!_uploadingImage)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.surfaceElevated, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.titleText,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _uploadingImage ? null : _showImageSourceSheet,
            child: Text(
              'Tap photo to change',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: t.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Name field ────────────────────────────────────
          _EditField(
            controller: _nameCtrl,
            label: 'Display Name',
            icon: Icons.person_outline_rounded,
            hint: 'Your name',
          ),
          const SizedBox(height: 14),

          // ── Email field ───────────────────────────────────
          _EditField(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            hint: 'your@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 28),

          // ── Save button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_saving || _uploadingImage) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(dynamic t, String initial) {
    return Container(
      color: t.primaryMuted,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: t.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Image Source Option Button ───────────────────────────────────────────────

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: t.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: t.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.titleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Edit Field ───────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.hintText,
              letterSpacing: 0.4,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, color: t.titleText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: t.hintText),
            prefixIcon: Icon(icon, size: 18, color: t.hintText),
            filled: true,
            fillColor: t.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: t.hintText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}


// ─── Grouped settings card ────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, indent: 62, color: t.divider),
          ],
        ],
      ),
    );
  }
}

// ─── Unified setting row ──────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final effectiveIconBg = isDestructive ? t.iconRed : iconBg;
    final titleColor = isDestructive ? t.danger : t.titleText;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: effectiveIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: t.bodyText,
                  ),
                ),
              ],
            ),
          ),
          // Trailing icon
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, size: 20, color: t.hintText),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: (isDestructive ? t.danger : t.primary)
            .withValues(alpha: 0.06),
        highlightColor: (isDestructive ? t.danger : t.primary)
            .withValues(alpha: 0.03),
        child: content,
      ),
    );
  }
}

// ─── Appearance card (compact: segmented theme toggle + small color dots) ─────

class _AppearanceCard extends StatelessWidget {
  final HelperProvider helper;
  const _AppearanceCard({required this.helper});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: helper.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.brightness_6_rounded,
                      size: 19, color: helper.primaryColor),
                ),
                const SizedBox(width: 14),
                Text(
                  'Theme',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: t.titleText,
                  ),
                ),
                const Spacer(),
                // Compact segmented toggle
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: t.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ThemeToggleBtn(
                        icon: Icons.brightness_auto_rounded,
                        selected: helper.themeMode == ThemeMode.system,
                        accent: helper.primaryColor,
                        onTap: () => helper.setThemeMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 2),
                      _ThemeToggleBtn(
                        icon: Icons.wb_sunny_rounded,
                        selected: helper.themeMode == ThemeMode.light,
                        accent: helper.primaryColor,
                        onTap: () => helper.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 2),
                      _ThemeToggleBtn(
                        icon: Icons.nightlight_rounded,
                        selected: helper.themeMode == ThemeMode.dark,
                        accent: helper.primaryColor,
                        onTap: () => helper.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, indent: 68, endIndent: 16, color: t.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: helper.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.language,
                      size: 19, color: helper.primaryColor),
                ),
                const SizedBox(width: 14),
                Text(
                  'Language',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: t.titleText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: t.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LanguageToggleBtn(
                        label: '🇰🇭',
                        selected: helper.locale.languageCode == 'km',
                        accent: helper.primaryColor,
                        onTap: () => helper.setLocale(const Locale('km')),
                      ),
                      const SizedBox(width: 2),
                      _LanguageToggleBtn(
                        label: '🇺🇸',
                        selected: helper.locale.languageCode == 'en',
                        accent: helper.primaryColor,
                        onTap: () => helper.setLocale(const Locale('en')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, indent: 68, endIndent: 16, color: t.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: helper.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.palette_rounded,
                      size: 19, color: helper.primaryColor),
                ),
                const SizedBox(width: 14),
                Text(
                  'Accent Color',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: t.titleText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  ..._kPresets.map(
                    (c) => _SmallSwatch(
                      color: c,
                      selected: helper.primaryColor.value == c.value,
                      onTap: () => helper.setPrimaryColor(c),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _SmallRainbow(
                    surfaceColor: t.surface,
                    onTap: () async {
                      final picked = await showDialog<Color>(
                        context: context,
                        builder: (_) =>
                            _ColorPickerDialog(initial: helper.primaryColor),
                      );
                      if (picked != null) {
                        helper.setPrimaryColor(picked);
                        showToast(context, 'Accent color updated',
                            type: ToastType.success);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Divider(height: 1, indent: 68, endIndent: 16, color: t.divider),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          //   child: Row(
          //     children: [
          //       Container(
          //         width: 38,
          //         height: 38,
          //         decoration: BoxDecoration(
          //           color: helper.primaryColor,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: const Icon(Icons.language,
          //             size: 19, color: Colors.white),
          //       ),
          //       const SizedBox(width: 14),
          //       Text(
          //         'Language',
          //         style: GoogleFonts.poppins(
          //           fontSize: 14.5,
          //           fontWeight: FontWeight.w500,
          //           color: t.titleText,
          //         ),
          //       ),
          //       const Spacer(),
          //       Container(
          //         padding: const EdgeInsets.all(3),
          //         decoration: BoxDecoration(
          //           color: t.surfaceElevated,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             _LanguageToggleBtn(
          //               label: '🇰🇭',
          //               selected: helper.locale.languageCode == 'km',
          //               accent: helper.primaryColor,
          //               onTap: () => helper.setLocale(const Locale('km')),
          //             ),
          //             const SizedBox(width: 2),
          //             _LanguageToggleBtn(
          //               label: '🇺🇸',
          //               selected: helper.locale.languageCode == 'en',
          //               accent: helper.primaryColor,
          //               onTap: () => helper.setLocale(const Locale('en')),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _ThemeToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ThemeToggleBtn({
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : context.appTheme.iconBlue,
        ),
      ),
    );
  }
}

// ─── Small color swatch (28 px) ───────────────────────────────────────────────

class _SmallSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SmallSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: selected ? Border.all(color: t.titleText, width: 2.5) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }
}

// ─── Small rainbow custom picker swatch ──────────────────────────────────────

class _SmallRainbow extends StatelessWidget {
  final VoidCallback onTap;
  final Color surfaceColor;

  const _SmallRainbow({required this.onTap, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.cyan,
            Colors.blue,
            Colors.purple,
            Colors.red,
          ]),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: surfaceColor),
          child: Icon(Icons.add_rounded,
              size: 13, color: context.appTheme.hintText),
        ),
      ),
    );
  }
}

// ─── Language toggle button ──────────────────────────────────────────────────

class _LanguageToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _LanguageToggleBtn({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? accent : context.appTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: selected ? Colors.white : context.appTheme.iconBlue,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Version footer ───────────────────────────────────────────────────────────

class _VersionFooter extends StatelessWidget {
  final AppLocalizations strings;
  const _VersionFooter({required this.strings});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Column(
      children: [
        Text(
          '${strings.version}   •   staging',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12, color: t.hintText),
        ),
        const SizedBox(height: 4),
        Text(
          strings.copyright,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11, color: t.hintText),
        ),
      ],
    );
  }
}

// ─── Full color picker dialog ─────────────────────────────────────────────────

class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selected;

  static const _allPresets = <Color>[
    Color(0xFF5C6BC0), Color(0xFF3949AB), Color(0xFF1E88E5),
    Color(0xFF039BE5), Color(0xFF00ACC1), Color(0xFF00897B),
    Color(0xFF43A047), Color(0xFF7CB342), Color(0xFFAFB800),
    Color(0xFFFDD835), Color(0xFFFB8C00), Color(0xFFF4511E),
    Color(0xFFE53935), Color(0xFFD81B60), Color(0xFF8E24AA),
    Color(0xFF5E35B1), Color(0xFF795548), Color(0xFF546E7A),
    Color(0xFF37474F), Color(0xFF757575),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return AlertDialog(
      title: Text('Choose Color',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _allPresets.map((c) {
          final isSel = c.value == _selected.value;
          return GestureDetector(
            onTap: () => setState(() => _selected = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c,
                border: isSel
                    ? Border.all(color: t.titleText, width: 3)
                    : null,
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSel
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text('Apply', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
