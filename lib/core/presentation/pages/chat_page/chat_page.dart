import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatPageProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatPageProvider>();
    final profile = context.watch<UserProfileProvider>().profile;
    final t = context.appTheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: t.surfaceElevated,
        body: SafeArea(
          child: Column(
            children: [
              _Header(t: t, l10n: l10n, profile: profile),
              _SearchBar(
                controller: _searchController,
                t: t,
                hint: l10n.chatSearchHint,
                onChanged: (q) => context.read<ChatPageProvider>().search(q),
              ),
              Expanded(
                child: provider.loading
                    ? Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: t.primary),
                      )
                    : () {
                        final displayUsers = provider.users
                            .where((user) => user.id != profile?.id)
                            .toList();
                        return displayUsers.isEmpty
                            ? _EmptyState(t: t, l10n: l10n)
                            : RefreshIndicator(
                                color: t.primary,
                                onRefresh: () => context.read<ChatPageProvider>().refresh(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                                  itemCount: displayUsers.length,
                                  itemBuilder: (context, index) {
                                    return _UserTile(
                                      user: displayUsers[index],
                                      t: t,
                                      isLast: index == displayUsers.length - 1,
                                    );
                                  },
                                ),
                              );
                      }(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.t,
    required this.l10n,
    this.profile,
  });

  final dynamic t;
  final AppLocalizations l10n;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl ?? '';
    final name = profile?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Text(
            l10n.chatTitle,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.appTheme.titleText,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.appTheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _HeaderInitial(initial: initial, t: t),
                    )
                  : _HeaderInitial(initial: initial, t: t),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInitial extends StatelessWidget {
  const _HeaderInitial({required this.initial, required this.t});
  final String initial;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.surface,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.primary,
        ),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.t,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final dynamic t;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: context.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 14, color: theme.bodyText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: theme.hintText,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.hintText,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }
}

// ── User tile ────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.t,
    required this.isLast,
  });

  final UserProfile user;
  final dynamic t;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final name = user.name ?? 'Unknown';
    final email = user.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final avatarUrl = user.avatarUrl ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                _Avatar(
                  avatarUrl: avatarUrl,
                  initial: initial,
                  theme: theme,
                ),
                const SizedBox(width: 14),

                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: theme.titleText,
                          height: 1.3,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: theme.hintText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Note badge
                if (user.isNote == true)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.primaryMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Note',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                  ),

                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.hintText.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.initial,
    required this.theme,
  });

  final String avatarUrl;
  final String initial;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarUrl.isEmpty ? t.primaryMuted : Colors.transparent,
        border: Border.all(
          color: t.divider.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(initial: initial, t: t),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: t.primary,
                      ),
                    ),
                  );
                },
              )
            : _Initials(initial: initial, t: t),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initial, required this.t});
  final String initial;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.primary,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t, required this.l10n});
  final dynamic t;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 34,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chatNoUsers,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.hintText,
            ),
          ),
        ],
      ),
    );
  }
}
