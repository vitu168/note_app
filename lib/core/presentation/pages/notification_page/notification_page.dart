import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/models/notification_item.dart';
import 'package:note_app/core/presentation/pages/notification_page/notification_page_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/core/theme/app_theme_extension.dart';
import 'package:note_app/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<NotificationPageProvider>();

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      body: SafeArea(
        child: Column(
          children: [
            _Header(t: t, l10n: l10n, provider: provider),
            Expanded(
              child: provider.items.isEmpty
                  ? _EmptyState(t: t, l10n: l10n)
                  : RefreshIndicator(
                      color: t.primary,
                      onRefresh: () async {},
                      child: _NotificationList(
                        items: provider.items,
                        t: t,
                        onTap: provider.markRead,
                        onDismiss: provider.remove,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.t, required this.l10n, required this.provider});
  final AppThemeExtension t;
  final AppLocalizations l10n;
  final NotificationPageProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.surface,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: t.titleText),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.notificationsTitle,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: t.titleText,
              ),
            ),
          ),
          if (provider.items.isNotEmpty) ...[
            TextButton(
              onPressed: provider.markAllRead,
              child: Text(
                l10n.markAllRead,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: t.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep_rounded, color: t.hintText),
              tooltip: l10n.clearAll,
              onPressed: () => _confirmClear(context),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          l10n.clearAll,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: t.titleText),
        ),
        content: Text(
          l10n.clearNotificationsConfirm,
          style: GoogleFonts.poppins(fontSize: 14, color: t.bodyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: GoogleFonts.poppins(color: t.hintText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.clear();
            },
            child: Text(l10n.clear, style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.items,
    required this.t,
    required this.onTap,
    required this.onDismiss,
  });
  final List<NotificationItem> items;
  final AppThemeExtension t;
  final void Function(int) onTap;
  final void Function(int) onDismiss;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: t.divider.withValues(alpha: 0.6)),
      itemBuilder: (context, index) {
        final item = items[index];
        return _NotificationTile(
          item: item,
          t: t,
          onTap: () => onTap(item.id),
          onDismiss: () => onDismiss(item.id),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.t,
    required this.onTap,
    required this.onDismiss,
  });
  final NotificationItem item;
  final AppThemeExtension t;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  String _timeLabel() {
    final now = DateTime.now();
    final diff = now.difference(item.receivedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade600,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? t.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: t.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: t.titleText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeLabel(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isUnread ? t.primary : t.hintText,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isUnread ? t.bodyText : t.hintText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (isUnread) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
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
  final AppThemeExtension t;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: t.surfaceHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 38,
              color: t.hintText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotifications,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: t.hintText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noNotificationsDesc,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: t.hintText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
