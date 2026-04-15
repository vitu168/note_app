import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:provider/provider.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/presentation/auth/welcome_page.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/utils/user_utils.dart';

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
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(strings.settings),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
            children: [
              // ── Profile ───────────────────────────────────────
              _ProfileBanner(helper: helper),
              const SizedBox(height: 28),

              // ── Appearance ────────────────────────────────────
              _SectionBlock(
                label: 'Appearance',
                child: _AppearanceCard(helper: helper),
              ),
              const SizedBox(height: 20),

              // ── Language ──────────────────────────────────────
              _SectionBlock(
                label: strings.appLanguage,
                child: _LanguageCard(helper: helper),
              ),
              const SizedBox(height: 20),

              // ── Security ──────────────────────────────────────
              _SectionBlock(
                label: strings.security,
                child: _SettingsGroup(children: [
                  _SettingRow(
                    icon: Icons.fingerprint_rounded,
                    iconBg: t.iconBlue,
                    title: strings.biometric,
                    subtitle: strings.biometricDesc,
                    trailing: Switch.adaptive(
                      value: false,
                      activeColor: helper.primaryColor,
                      onChanged: (v) => showToast(
                        context,
                        'Biometric lock ${v ? "enabled" : "disabled"}',
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Notifications ─────────────────────────────────
              _SectionBlock(
                label: strings.notifications,
                child: _SettingsGroup(children: [
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    iconBg: t.iconOrange,
                    title: strings.enableNotifications,
                    subtitle: strings.notificationsDesc,
                    trailing: Switch.adaptive(
                      value: false,
                      activeColor: helper.primaryColor,
                      onChanged: (v) => showToast(
                        context,
                        strings.notificationSettingsUpdated,
                        type: ToastType.info,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Account ───────────────────────────────────────
              _SectionBlock(
                label: strings.account,
                child: _SettingsGroup(children: [
                  _SettingRow(
                    icon: Icons.grid_view_rounded,
                    iconBg: t.iconTeal,
                    title: strings.gridView,
                    subtitle: strings.gridViewDesc,
                    onTap: () => showToast(
                      context,
                      'View preference updated',
                      type: ToastType.info,
                    ),
                  ),
                  _SettingRow(
                    icon: Icons.feedback_outlined,
                    iconBg: t.iconGreen,
                    title: strings.feedback,
                    subtitle: strings.feedbackDesc,
                    onTap: () =>
                        showToast(context, strings.feedbackComingSoon),
                  ),
                  _SettingRow(
                    icon: Icons.delete_outline_rounded,
                    iconBg: t.iconRed,
                    title: strings.clearNotes,
                    subtitle: strings.clearNotesDesc,
                    isDestructive: true,
                    onTap: () => _showClearDialog(context, strings),
                  ),
                  _SettingRow(
                    icon: Icons.logout_rounded,
                    iconBg: t.iconRed,
                    title: strings.logout,
                    subtitle: strings.logoutDesc,
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context, strings),
                  ),
                ]),
              ),
              const SizedBox(height: 36),

              // ── Footer ────────────────────────────────────────
              _VersionFooter(strings: strings),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showClearDialog(BuildContext context, AppLocalizations strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.clearNotes),
        content: Text(strings.clearNotesDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: context.appTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              showToast(context, '${strings.clearNotes}!');
            },
            child: Text(strings.clear),
          ),
        ],
      ),
    );
  }

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

// ─── Profile banner ───────────────────────────────────────────────────────────

class _ProfileBanner extends StatelessWidget {
  final HelperProvider helper;
  const _ProfileBanner({required this.helper});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser();
    final meta = user?.userMetadata;
    final rawName = meta != null
        ? (meta['name'] ??
                meta['full_name'] ??
                meta['preferred_username'] ??
                meta['display_name'])
            ?.toString()
        : null;
    final name =
        (rawName != null && rawName.trim().isNotEmpty)
            ? rawName
            : extractNameFromEmail(user?.email);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            helper.primaryColor,
            Color.lerp(helper.primaryColor, Colors.deepPurple, 0.28)!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: helper.primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35), width: 2),
            ),
            child:
                const Icon(Icons.person_rounded, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Name / email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Edit button
          Material(
            color: Colors.white.withValues(alpha: 0.15),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () =>
                  showToast(context, AppLocalizations.of(context).editSoon),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.edit_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section wrapper (label + rounded card) ──────────────────────────────────

class _SectionBlock extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.hintText,
              letterSpacing: 0.9,
            ),
          ),
        ),
        child,
      ],
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

  /// Custom trailing widget. When null: shows chevron for tappable rows,
  /// or nothing if [onTap] is also null.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailing,
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
          // Trailing
          if (trailing != null)
            trailing!
          else if (onTap != null)
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

// ─── Appearance card (theme chips + color swatches) ───────────────────────────

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: helper.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.palette_rounded,
                      size: 19, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: t.titleText,
                        ),
                      ),
                      Text(
                        'Theme mode & accent color',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: t.bodyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Theme mode chips ─────────────────────────────
            Row(
              children: [
                _ThemeChip(
                  icon: Icons.brightness_auto_rounded,
                  label: 'System',
                  selected: helper.themeMode == ThemeMode.system,
                  accent: helper.primaryColor,
                  onTap: () => helper.setThemeMode(ThemeMode.system),
                ),
                const SizedBox(width: 8),
                _ThemeChip(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Light',
                  selected: helper.themeMode == ThemeMode.light,
                  accent: helper.primaryColor,
                  onTap: () => helper.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemeChip(
                  icon: Icons.nightlight_rounded,
                  label: 'Dark',
                  selected: helper.themeMode == ThemeMode.dark,
                  accent: helper.primaryColor,
                  onTap: () => helper.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: t.divider),
            const SizedBox(height: 14),

            // ── Accent color label ───────────────────────────
            Text(
              'Accent Color',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: t.bodyText,
              ),
            ),
            const SizedBox(height: 12),

            // ── Swatches + rainbow picker ────────────────────
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._kPresets.map(
                  (c) => _ColorSwatch(
                    color: c,
                    selected: helper.primaryColor.value == c.value,
                    onTap: () => helper.setPrimaryColor(c),
                  ),
                ),
                _RainbowSwatch(
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
          ],
        ),
      ),
    );
  }
}

// ─── Theme mode chip ──────────────────────────────────────────────────────────

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : t.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18, color: selected ? accent : t.hintText),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? accent : t.hintText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Color swatch circle ──────────────────────────────────────────────────────

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected
              ? Border.all(color: t.titleText, width: 2.5)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

// ─── Rainbow custom-color swatch ─────────────────────────────────────────────

class _RainbowSwatch extends StatelessWidget {
  final VoidCallback onTap;
  final Color surfaceColor;

  const _RainbowSwatch({
    required this.onTap,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
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
          margin: const EdgeInsets.all(5),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: surfaceColor),
          child: Icon(Icons.add_rounded,
              size: 17, color: context.appTheme.hintText),
        ),
      ),
    );
  }
}

// ─── Language card ────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  final HelperProvider helper;
  const _LanguageCard({required this.helper});

  static const _langs = [
    _LangOption(
        locale: Locale('km'),
        flag: '🇰🇭',
        label: 'ភាសាខ្មែរ',
        code: 'km-KH'),
    _LangOption(
        locale: Locale('en'),
        flag: '🇺🇸',
        label: 'English',
        code: 'en-US'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final current = helper.locale.languageCode;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language_rounded,
                      size: 19, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).appLanguage,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: t.titleText,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).chooseLanguage,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: t.bodyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: t.divider),
            const SizedBox(height: 14),

            // Language pills
            Row(
              children: _langs.asMap().entries.map((e) {
                final lang = e.value;
                final isLast = e.key == _langs.length - 1;
                final sel = current == lang.locale.languageCode;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 10),
                    child: GestureDetector(
                      onTap: () => helper.setLocale(lang.locale),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? helper.primaryColor.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? helper.primaryColor
                                : t.divider,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang.flag,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: sel
                                          ? helper.primaryColor
                                          : t.titleText,
                                    ),
                                  ),
                                  Text(
                                    lang.code,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10, color: t.hintText),
                                  ),
                                ],
                              ),
                            ),
                            if (sel) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.check_circle_rounded,
                                  size: 15,
                                  color: helper.primaryColor),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  final Locale locale;
  final String flag;
  final String label;
  final String code;

  const _LangOption({
    required this.locale,
    required this.flag,
    required this.label,
    required this.code,
  });
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
          style: GoogleFonts.poppins(fontSize: 11, color: t.divider),
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
