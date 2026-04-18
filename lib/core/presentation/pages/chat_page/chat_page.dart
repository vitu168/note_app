import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/core/presentation/widgets/skeleton/user_tile_skeleton.dart';
import 'package:note_app/l10n/app_localizations.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_detail_page.dart';

/// Format a [DateTime] into a compact chat-list time string.
String _formatPreviewTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final local = dt.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(local.year, local.month, local.day);
  final diff = today.difference(msgDay).inDays;
  if (diff == 0) {
    final h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }
  if (diff == 1) return 'Yesterday';
  const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  if (diff < 7) return weekdays[local.weekday];
  return '${local.month}/${local.day}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

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
      final provider = context.read<ChatPageProvider>();
      final profile = context.read<UserProfileProvider>().profile;
      provider.loadUsers(currentUserId: profile?.id);
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
              _Header(profile: profile, t: t, unreadCount: provider.unreadCount),
              _SearchBar(
                controller: _searchController,
                t: t,
                hint: l10n.chatSearchHint,
                onChanged: (q) => context.read<ChatPageProvider>().search(q),
              ),
              Expanded(
                child: provider.loading
                    ? const UserListSkeleton()
                    : () {
                        final displayUsers = provider.users
                            .where((u) => u.id != profile?.id)
                            .toList();
                        if (displayUsers.isEmpty) {
                          return _EmptyState(t: t, l10n: l10n);
                        }
                        return RefreshIndicator(
                          color: t.primary,
                          onRefresh: () => context
                              .read<ChatPageProvider>()
                              .refresh(currentUserId: profile?.id),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.only(top: 4, bottom: 100),
                            itemCount: displayUsers.length,
                            itemBuilder: (context, index) {
                              final user = displayUsers[index];
                              return _ConvTile(
                                user: user,
                                preview: provider.previewFor(user.id),
                                t: t,
                                currentUserId: profile?.id ?? '',
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

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.t, required this.unreadCount});
  final UserProfile? profile;
  final dynamic t;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final avatarUrl = profile?.avatarUrl ?? '';
    final name = profile?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        children: [
          // Avatar (own profile)
          _AvatarWidget(avatarUrl: avatarUrl, initial: initial, size: 38, t: theme),
          const SizedBox(width: 12),
          Text(
            'Messages',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.titleText,
              height: 1.2,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Compose button
          Material(
            color: theme.primaryMuted,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.edit_rounded, size: 20, color: theme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surfaceHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 14, color: theme.bodyText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: theme.hintText, fontSize: 14),
            prefixIcon:
                Icon(Icons.search_rounded, color: theme.hintText, size: 20),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation tile — Messenger / Telegram style
// ─────────────────────────────────────────────────────────────────────────────

class _ConvTile extends StatelessWidget {
  const _ConvTile({
    required this.user,
    required this.preview,
    required this.t,
    required this.currentUserId,
  });
  final UserProfile user;
  final ConversationPreview? preview;
  final dynamic t;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final name = user.name ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatarUrl = user.avatarUrl ?? '';
    final lastMsg = preview?.lastMessage;
    final timeStr = _formatPreviewTime(preview?.lastMessageTime);
    final hasUnread = (preview?.unreadCount ?? 0) > 0;
    final isMine = preview?.isLastMessageMine ?? false;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetailPage(otherUser: user, currentUserId: currentUserId)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Avatar ─────────────────────────────────────────────────────
            _AvatarWidget(
              avatarUrl: avatarUrl,
              initial: initial,
              size: 54,
              t: theme,
            ),
            const SizedBox(width: 14),

            // ── Name + last message ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: theme.titleText,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: hasUnread ? theme.primary : theme.hintText,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Last message row + unread badge
                  Row(
                    children: [
                      // Sent tick for own messages
                      if (isMine) ...[
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          lastMsg ?? 'Tap to start chatting',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: hasUnread
                                ? theme.bodyText
                                : theme.hintText,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (preview?.unreadCount ?? 0) > 99
                                ? '99+'
                                : '${preview?.unreadCount ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared avatar widget
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.avatarUrl,
    required this.initial,
    required this.size,
    required this.t,
  });
  final String avatarUrl;
  final String initial;
  final double size;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(theme, size),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _fallback(theme, size);
          },
        ),
      );
    }
    return _fallback(theme, size);
  }

  Widget _fallback(dynamic theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.7),
            theme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: theme.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

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
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 32, color: theme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chatNoUsers,
            style: GoogleFonts.poppins(fontSize: 14, color: theme.hintText),
          ),
        ],
      ),
    );
  }
}
