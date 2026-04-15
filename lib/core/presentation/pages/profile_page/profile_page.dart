import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/presentation/utils/user_utils.dart';
import 'package:note_app/core/presentation/widgets/skeleton/shimmer_box.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _userEmail;
  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _authSub = AuthService.onAuthStateChange().listen((_) => _loadUser());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _loadUser() {
    final user = AuthService.currentUser();
    final meta = user?.userMetadata;
    setState(() {
      _userEmail = user?.email;
      _userName = meta != null
          ? (meta['name'] ??
                  meta['full_name'] ??
                  meta['preferred_username'] ??
                  meta['display_name'])
              ?.toString()
          : null;
      if ((_userName == null || _userName!.trim().isEmpty) &&
          _userEmail != null) {
        _userName = extractNameFromEmail(_userEmail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final profileProvider = context.watch<UserProfileProvider>();
    final homeProvider = context.watch<HomePageProvider>();
    final totalNotes = homeProvider.notes.length;
    final favoriteCount = homeProvider.notes.where((n) => n.isFavorites).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.profile,
          style: GoogleFonts.poppins(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Avatar
            if (profileProvider.loading && profileProvider.profile == null) ...[
              const ShimmerBox(width: 104, height: 104, borderRadius: 52),
              const SizedBox(height: 16),
              ShimmerBox(width: 160, height: 22, borderRadius: 8),
              const SizedBox(height: 8),
              ShimmerBox(width: 200, height: 14, borderRadius: 6),
            ] else ...[
              CircleAvatar(
                radius: 52,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                _userName ?? l10n.profileName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                _userEmail ?? l10n.profileEmail,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Stats row
            if (homeProvider.loading)
              Row(
                children: [
                  Expanded(
                    child: _StatCardSkeleton(theme: theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCardSkeleton(theme: theme),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '$totalNotes',
                      label: l10n.notes,
                      icon: Icons.note_rounded,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      value: '$favoriteCount',
                      label: l10n.favorites,
                      icon: Icons.star_rounded,
                      theme: theme,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 28),

            // Backend profile info
            if (profileProvider.loading && profileProvider.profile == null)
              _InfoSectionSkeleton(theme: theme)
            else if (profileProvider.profile != null) ...[
              _InfoSection(
                title: 'Account Info',
                theme: theme,
                children: [
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: profileProvider.profile!.id,
                    theme: theme,
                  ),
                  if (profileProvider.profile!.email != null)
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profileProvider.profile!.email!,
                      theme: theme,
                    ),
                  if (profileProvider.profile!.name != null)
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      value: profileProvider.profile!.name!,
                      theme: theme,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ThemeData theme;

  const _InfoSection({
    required this.title,
    required this.children,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card skeleton ────────────────────────────────────────────────────────

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ShimmerBox(width: 28, height: 28, borderRadius: 6),
          const SizedBox(height: 10),
          ShimmerBox(width: 48, height: 28, borderRadius: 8),
          const SizedBox(height: 6),
          ShimmerBox(width: 56, height: 13, borderRadius: 5),
        ],
      ),
    );
  }
}

// ── Info section skeleton ─────────────────────────────────────────────────────

class _InfoSectionSkeleton extends StatelessWidget {
  const _InfoSectionSkeleton({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 100, height: 13, borderRadius: 5),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    ShimmerBox(width: 18, height: 18, borderRadius: 5),
                    const SizedBox(width: 12),
                    ShimmerBox(width: 56, height: 13, borderRadius: 5),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 13, borderRadius: 5),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
