import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:provider/provider.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/presentation/auth/welcome_page.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/utils/user_utils.dart';
import 'package:note_app/core/presentation/components/language_dropdown.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final helperProvider = Provider.of<HelperProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          children: [
            // Profile Card
            Card(
              elevation: 0,
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.only(bottom: 28),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Row(
                  children: [
                    // Avatar with border and shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.18),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.13),
                        child: Icon(Icons.person,
                            size: 38,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Name and email
                    Expanded(
                      child: Builder(builder: (ctx) {
                        final user = AuthService.currentUser();
                        final meta = user?.userMetadata;
                        final displayName = meta != null
                            ? (meta['name'] ?? meta['full_name'] ?? meta['preferred_username'] ?? meta['display_name'])?.toString()
                            : null;
                        final name = (displayName != null && displayName.trim().isNotEmpty)
                            ? displayName
                            : extractNameFromEmail(user?.email);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.email ?? 'Email',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    Material(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          showToast(context, AppLocalizations.of(context).editSoon);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.edit,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // General Section
            _sectionHeader(context, AppLocalizations.of(context).general),
            _animatedSetting(
              child: _settingCard(
                context: context,
                child: SwitchListTile(
                  secondary: _leadingIcon(context, Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                  title: Text(AppLocalizations.of(context).darkMode,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).darkModeDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  value: helperProvider.isDarkMode,
                  onChanged: (value) {
                    helperProvider.toggleTheme();
                    showToast(context, 'Theme switched to ${value ? "Dark" : "Light"} mode', type: ToastType.success);
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            _animatedSetting(
              delay: 100,
              child: _settingCard(
                context: context,
                child: SwitchListTile(
                  secondary: _leadingIcon(context, Icons.grid_view, color: Theme.of(context).colorScheme.primary),
                  title: Text(AppLocalizations.of(context).gridView,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).gridViewDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  value: true,
                  onChanged: (value) {
                    showToast(context, 'View preference updated', type: ToastType.info);
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            _animatedSetting(
              delay: 120,
              child: _settingCard(
                context: context,
                child: ListTile(
                  leading: _leadingIcon(context, Icons.language, color: Theme.of(context).colorScheme.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(AppLocalizations.of(context).appLanguage,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).chooseLanguage,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  trailing: const LanguageDropdown(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Security Section
            _sectionHeader(context, AppLocalizations.of(context).security),
            _animatedSetting(
              delay: 150,
              child: _settingCard(
                context: context,
                child: SwitchListTile(
                  secondary: _leadingIcon(context, Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
                  title: Text(AppLocalizations.of(context).biometric,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).biometricDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  value: false,
                  onChanged: (value) {
                    showToast(context, 'Biometric lock ${value ? "enabled" : "disabled"}');
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Notifications Section
            _sectionHeader(context, AppLocalizations.of(context).notifications),
            _animatedSetting(
              delay: 200,
              child: _settingCard(
                context: context,
                child: SwitchListTile(
                  secondary: _leadingIcon(context, Icons.notifications, color: Theme.of(context).colorScheme.primary),
                  title: Text(AppLocalizations.of(context).enableNotifications,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).notificationsDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  value: false,
                  onChanged: (value) {
                    showToast(context, AppLocalizations.of(context).notificationSettingsUpdated, type: ToastType.info);
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 28),
            _sectionHeader(context, AppLocalizations.of(context).account),
            _animatedSetting(
              delay: 300,
              child: _settingCard(
                context: context,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(AppLocalizations.of(context).clearNotes,
                      style:
                          GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                  subtitle: Text(
                    AppLocalizations.of(context).clearNotesDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  trailing: const Icon(Icons.delete_outline, color: Colors.red),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context).clearNotes,
                            style: GoogleFonts.poppins()),
                        content: Text(AppLocalizations.of(context).clearNotesDesc,
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context).cancel,
                                style: GoogleFonts.poppins()),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showToast(context, '${AppLocalizations.of(context).clearNotes}!');
                            },
                            child: Text(AppLocalizations.of(context).clear,
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _animatedSetting(
              delay: 350,
              child: _settingCard(
                context: context,
                child: ListTile(
                  leading: _leadingIcon(context, Icons.feedback_outlined, color: Theme.of(context).colorScheme.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(AppLocalizations.of(context).feedback,
                      style: GoogleFonts.poppins(fontSize: 16)),
                  subtitle: Text(
                    AppLocalizations.of(context).feedbackDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () {
                    showToast(context, AppLocalizations.of(context).feedbackComingSoon);
                  },
                ),
              ),
            ),
            _animatedSetting(
              delay: 400,
              child: _settingCard(
                context: context,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(AppLocalizations.of(context).logout,
                      style:
                          GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                  subtitle: Text(
                    AppLocalizations.of(context).logoutDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)),
                  ),
                  trailing: const Icon(Icons.logout, color: Colors.red),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context).logoutQ,
                            style: GoogleFonts.poppins()),
                        content: Text(AppLocalizations.of(context).logoutConfirm,
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context).cancel,
                                style: GoogleFonts.poppins()),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              // show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );

                              try {
                                await AuthService.signOut().timeout(const Duration(seconds: 5));

                                Navigator.pop(context); // close loading
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                                  (route) => false,
                                );

                                showToast(context, '${AppLocalizations.of(context).logout} successful');
                              } on TimeoutException {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                                  (route) => false,
                                );

                                showToast(context, 'Sign out timed out — you have been signed out locally.');
                                unawaited(AuthService.signOut().catchError((_) {}));
                              } catch (e) {
                                Navigator.pop(context); // close loading
                                showToast(context, 'Logout failed: $e');
                              }
                            },
                            child: Text(AppLocalizations.of(context).logout,
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _animatedSetting(
              delay: 450,
              child: ListTile(
                title: Text(AppLocalizations.of(context).about,
                    style: GoogleFonts.poppins(fontSize: 16)),
                subtitle: Text(
                  AppLocalizations.of(context).version,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7)),
                ),
                trailing: Icon(Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Note App',
                    applicationVersion: AppLocalizations.of(context).version,
                    applicationLegalese: AppLocalizations.of(context).copyright,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section header widget
  Widget _sectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

  // Animated setting tile wrapper
  Widget _animatedSetting({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _settingCard({required BuildContext context, required Widget child}) {
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: child,
      ),
    );
  }

  Widget _leadingIcon(BuildContext context, IconData icon, {Color? color}) {
    final bg = (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.12);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 20),
      ),
    );
  }
}
