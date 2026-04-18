import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/models/chat_messenger_message.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_detail_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/core/theme/app_theme_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({
    super.key,
    required this.otherUser,
    required this.currentUserId,
  });
  final UserProfile otherUser;
  final String currentUserId;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isInputEmpty = true;
  String? _replyingTo;
  bool _showEmoji = false;

  late final ChatDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ChatDetailProvider(
      otherUser: widget.otherUser,
      currentUserId: widget.currentUserId,
    );
    _inputCtrl.addListener(() {
      final empty = _inputCtrl.text.trim().isEmpty;
      if (empty != _isInputEmpty) setState(() => _isInputEmpty = empty);
    });
    _provider.init();
    _provider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    // Scroll to bottom whenever new messages arrive or send completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && _scrollCtrl.position.pixels < 80) {
        // Already near bottom — keep at bottom
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
    // Show snackbar when send fails
    if (_provider.optimisticFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send. Tap to retry.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _provider.retryFailedSend,
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _setReply(String text) {
    setState(() => _replyingTo = text);
    HapticFeedback.lightImpact();
  }

  void _clearReply() => setState(() => _replyingTo = null);

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    _clearReply();
    HapticFeedback.lightImpact();
    await _provider.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final name = widget.otherUser.name ?? 'User';

    return ChangeNotifierProvider<ChatDetailProvider>.value(
      value: _provider,
      child: Consumer<ChatDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: t.surfaceElevated,
            appBar: _AppBar(
              name: name,
              otherUser: widget.otherUser,
              t: t,
            ),
            body: Column(
              children: [
                // ── Error banner ───────────────────────────────────────────
                if (provider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.red.shade600,
                    child: Text(
                      provider.error!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // ── Messages area ──────────────────────────────────────────
                Expanded(
                  child: provider.loading
                      ? _LoadingSkeleton(t: t)
                      : provider.messages.isEmpty &&
                              provider.optimisticContent == null
                          ? _EmptyState(t: t)
                          : RefreshIndicator(
                              onRefresh: provider.refresh,
                              color: t.primary,
                              child: _MessagesList(
                                messages: provider.messages,
                                optimisticContent: provider.optimisticContent,
                                optimisticFailed: provider.optimisticFailed,
                                currentUserId: widget.currentUserId,
                                otherUser: widget.otherUser,
                                t: t,
                                scrollCtrl: _scrollCtrl,
                                onReply: _setReply,
                                onDelete: provider.deleteMessage,
                              ),
                            ),
                ),
                // ── Reply bar ──────────────────────────────────────────────
                if (_replyingTo != null)
                  _ReplyBar(
                    text: _replyingTo!,
                    onClose: _clearReply,
                    t: t,
                  ),
                // ── Input bar ──────────────────────────────────────────────
                _InputBar(
                  controller: _inputCtrl,
                  isInputEmpty: _isInputEmpty,
                  showEmoji: _showEmoji,
                  sending: provider.sending,
                  t: t,
                  onSend: _sendMessage,
                  onAttach: () {},
                  onEmojiToggle: () =>
                      setState(() => _showEmoji = !_showEmoji),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.name,
    required this.otherUser,
    required this.t,
  });
  final String name;
  final UserProfile otherUser;
  final AppThemeExtension t;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
          bottom: BorderSide(color: t.divider.withValues(alpha: 0.12)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          SizedBox(
            height: 63,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: t.titleText, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  _Avatar(user: otherUser, t: t, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: t.titleText,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: t.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Active now',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: t.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _AppBarBtn(
                    icon: Icons.videocam_rounded,
                    color: t.primary,
                    onTap: () {},
                  ),
                  _AppBarBtn(
                    icon: Icons.call_rounded,
                    color: t.primary,
                    onTap: () {},
                  ),
                  _AppBarBtn(
                    icon: Icons.more_vert_rounded,
                    color: t.bodyText,
                    onTap: () => _showMoreSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MoreSheet(t: t),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  const _AppBarBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Messages list — date grouping + consecutive bubble grouping
// ─────────────────────────────────────────────────────────────────────────────

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.optimisticContent,
    required this.optimisticFailed,
    required this.currentUserId,
    required this.otherUser,
    required this.t,
    required this.scrollCtrl,
    required this.onReply,
    required this.onDelete,
  });

  final List<ChatMessengerMessage> messages;
  final String? optimisticContent;
  final bool optimisticFailed;
  final String currentUserId;
  final UserProfile otherUser;
  final AppThemeExtension t;
  final ScrollController scrollCtrl;
  final void Function(String) onReply;
  final void Function(int) onDelete;

  // Build a flat list of items: either a date header or a message index
  List<Object> _buildItems() {
    final items = <Object>[];
    DateTime? lastDate;

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final date = DateTime(
        msg.createdAt.toLocal().year,
        msg.createdAt.toLocal().month,
        msg.createdAt.toLocal().day,
      );
      if (lastDate == null || !_isSameDay(lastDate, date)) {
        items.add(date); // date separator
        lastDate = date;
      }
      items.add(i); // message index
    }

    // Optimistic bubble always at end (same day as today)
    if (optimisticContent != null) {
      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      if (lastDate == null || !_isSameDay(lastDate, todayDay)) {
        items.add(todayDay);
      }
      items.add(-1); // sentinel for optimistic
    }

    return items;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return ListView.builder(
      controller: scrollCtrl,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: items.length,
      itemBuilder: (context, reversedIdx) {
        final item = items[items.length - 1 - reversedIdx];

        // Date separator
        if (item is DateTime) {
          return _DateChip(date: item, t: t);
        }

        final idx = item as int;

        // Optimistic bubble
        if (idx == -1) {
          return _OptimisticBubble(
            content: optimisticContent!,
            failed: optimisticFailed,
            t: t,
          );
        }

        final msg = messages[idx];
        final isMe = msg.senderId == currentUserId;

        // Grouping: is this consecutive from the same sender?
        final prevMsg = idx > 0 ? messages[idx - 1] : null;
        final nextMsg = idx < messages.length - 1 ? messages[idx + 1] : null;

        final isFirstInGroup = prevMsg == null ||
            prevMsg.senderId != msg.senderId ||
            msg.createdAt.difference(prevMsg.createdAt).inMinutes > 3;

        final isLastInGroup = nextMsg == null ||
            nextMsg.senderId != msg.senderId ||
            nextMsg.createdAt.difference(msg.createdAt).inMinutes > 3;

        return _BubbleWrapper(
          key: ValueKey(msg.id),
          msg: msg,
          isMe: isMe,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
          t: t,
          otherUser: otherUser,
          onReply: onReply,
          onDelete: onDelete,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleWrapper extends StatelessWidget {
  const _BubbleWrapper({
    super.key,
    required this.msg,
    required this.isMe,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.t,
    required this.otherUser,
    required this.onReply,
    required this.onDelete,
  });

  final ChatMessengerMessage msg;
  final bool isMe;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final AppThemeExtension t;
  final UserProfile otherUser;
  final void Function(String) onReply;
  final void Function(int) onDelete;

  String get _timeStr {
    final dt = msg.createdAt.toLocal();
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: isLastInGroup ? 6 : 2,
          top: isFirstInGroup ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Other user avatar — only show on last bubble in group
            if (!isMe) ...[
              SizedBox(
                width: 34,
                child: isLastInGroup
                    ? _SmallAvatar(user: otherUser, t: t)
                    : null,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  _Bubble(
                    content: msg.content,
                    isMe: isMe,
                    isFirst: isFirstInGroup,
                    isLast: isLastInGroup,
                    t: t,
                  ),
                  if (isLastInGroup) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeStr,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: t.hintText,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 3),
                          Icon(
                            msg.isRead
                                ? Icons.done_all_rounded
                                : Icons.check_rounded,
                            size: 13,
                            color: msg.isRead ? t.primary : t.hintText,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MessageOptionsSheet(
        isMe: isMe,
        t: t,
        onReply: () {
          Navigator.pop(context);
          onReply(msg.content);
        },
        onCopy: () {
          Navigator.pop(context);
          Clipboard.setData(ClipboardData(text: msg.content));
        },
        onDelete: () {
          Navigator.pop(context);
          if (isMe) onDelete(msg.id);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Optimistic bubble (in-flight / failed send)
// ─────────────────────────────────────────────────────────────────────────────

class _OptimisticBubble extends StatelessWidget {
  const _OptimisticBubble({
    required this.content,
    required this.failed,
    required this.t,
  });
  final String content;
  final bool failed;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Opacity(
                  opacity: failed ? 1.0 : 0.6,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: failed ? Colors.red.shade400 : t.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      content,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (failed)
                      Text(
                        'Failed to send',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      )
                    else
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: t.hintText,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble shape (Facebook Messenger style — adjacent bubbles share corners)
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.content,
    required this.isMe,
    required this.isFirst,
    required this.isLast,
    required this.t,
  });
  final String content;
  final bool isMe;
  final bool isFirst;
  final bool isLast;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(20);
    const rSmall = Radius.circular(4);

    // FB Messenger: tail only on the first/last bubble of a group
    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: r,
            topRight: isFirst ? r : rSmall,
            bottomLeft: r,
            bottomRight: isLast ? rSmall : rSmall,
          )
        : BorderRadius.only(
            topLeft: isFirst ? r : rSmall,
            topRight: r,
            bottomLeft: isLast ? rSmall : rSmall,
            bottomRight: r,
          );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? t.primary : t.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          color: isMe ? Colors.white : t.bodyText,
          height: 1.45,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date chip with smart label
// ─────────────────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date, required this.t});
  final DateTime date;
  final AppThemeExtension t;

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(date.year, date.month, date.day);

    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';

    // Within this year: "Apr 15"; older: "Apr 15, 2024"
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = months[date.month];
    if (date.year == now.year) return '$monthStr ${date.day}';
    return '$monthStr ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: t.surfaceHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: t.hintText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty & loading states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t});
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👋', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: t.titleText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Say hello and start the conversation!',
            style: GoogleFonts.poppins(fontSize: 13, color: t.hintText),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.t});
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      itemCount: 6,
      itemBuilder: (_, i) {
        final isMe = i.isEven;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                width: 120 + (i * 20.0) % 80,
                height: 42,
                decoration: BoxDecoration(
                  color: t.surfaceHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reply bar above input
// ─────────────────────────────────────────────────────────────────────────────

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({
    required this.text,
    required this.onClose,
    required this.t,
  });
  final String text;
  final VoidCallback onClose;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: t.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.primary,
                  ),
                ),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.poppins(fontSize: 12.5, color: t.hintText),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: t.surfaceHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 16, color: t.hintText),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input bar
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isInputEmpty,
    required this.showEmoji,
    required this.sending,
    required this.t,
    required this.onSend,
    required this.onAttach,
    required this.onEmojiToggle,
  });
  final TextEditingController controller;
  final bool isInputEmpty;
  final bool showEmoji;
  final bool sending;
  final AppThemeExtension t;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onEmojiToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CircleBtn(
            icon: Icons.add_rounded,
            color: t.primary,
            bg: t.primaryMuted,
            onTap: onAttach,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 130),
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.circular(26),
                border:
                    Border.all(color: t.divider.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.poppins(
                          fontSize: 14.5, color: t.bodyText),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14.5, color: t.hintText),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 10, 4, 10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: GestureDetector(
                      onTap: onEmojiToggle,
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(
                          showEmoji
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_outlined,
                          color: t.hintText,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(
                  parent: anim, curve: Curves.elasticOut),
              child: child,
            ),
            child: isInputEmpty
                ? _CircleBtn(
                    key: const ValueKey('mic'),
                    icon: Icons.mic_rounded,
                    color: t.primary,
                    bg: t.primaryMuted,
                    onTap: () {},
                  )
                : _CircleBtn(
                    key: const ValueKey('send'),
                    icon: Icons.send_rounded,
                    color: Colors.white,
                    bg: t.primary,
                    onTap: sending ? () {} : onSend,
                    size: 46,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.size = 42,
  });
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.48),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.user, required this.t});
  final UserProfile user;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl ?? '';
    final initial = (user.name ?? 'U').isNotEmpty
        ? user.name![0].toUpperCase()
        : 'U';
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: url.isEmpty
            ? LinearGradient(
                colors: [
                  t.primary.withValues(alpha: 0.75),
                  t.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialText(initial: initial, size: 30, color: t.onPrimary),
              )
            : _InitialText(initial: initial, size: 30, color: t.onPrimary),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.t, required this.size});
  final UserProfile user;
  final AppThemeExtension t;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl ?? '';
    final initial = (user.name ?? 'U').isNotEmpty
        ? user.name![0].toUpperCase()
        : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: url.isEmpty
            ? LinearGradient(
                colors: [
                  t.primary.withValues(alpha: 0.8),
                  t.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialText(initial: initial, size: size, color: t.onPrimary),
              )
            : _InitialText(initial: initial, size: size, color: t.onPrimary),
      ),
    );
  }
}

class _InitialText extends StatelessWidget {
  const _InitialText({
    required this.initial,
    required this.size,
    required this.color,
  });
  final String initial;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message options sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MessageOptionsSheet extends StatelessWidget {
  const _MessageOptionsSheet({
    required this.isMe,
    required this.t,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
  });
  final bool isMe;
  final AppThemeExtension t;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: t.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Quick emoji reactions
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: emojis
                    .map(
                      (e) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(e,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            _SheetTile(
              icon: Icons.reply_rounded,
              label: 'Reply',
              color: t.bodyText,
              t: t,
              onTap: onReply,
            ),
            _SheetTile(
              icon: Icons.copy_rounded,
              label: 'Copy',
              color: t.bodyText,
              t: t,
              onTap: onCopy,
            ),
            if (isMe)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: t.danger,
                t: t,
                onTap: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.t,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final AppThemeExtension t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// More options sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.t});
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: t.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            _SheetTile(
              icon: Icons.search_rounded,
              label: 'Search in conversation',
              color: t.bodyText,
              t: t,
              onTap: () => Navigator.pop(context),
            ),
            _SheetTile(
              icon: Icons.notifications_off_outlined,
              label: 'Mute notifications',
              color: t.bodyText,
              t: t,
              onTap: () => Navigator.pop(context),
            ),
            _SheetTile(
              icon: Icons.block_rounded,
              label: 'Block user',
              color: t.danger,
              t: t,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
