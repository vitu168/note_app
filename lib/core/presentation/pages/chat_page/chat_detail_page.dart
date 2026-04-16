import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/core/theme/app_theme_extension.dart';

class _MockMsg {
  const _MockMsg({
    required this.text,
    required this.isMe,
    required this.time,
    this.reactions = const [],
    this.replyTo,
    this.isRead = true,
  });
  final String text;
  final bool isMe;
  final String time;
  final List<String> reactions;
  final String? replyTo;
  final bool isRead;
}

const _mockMessages = [
  _MockMsg(text: 'សួស្តី 👋', isMe: false, time: '9:01 AM'),
  _MockMsg(
    text: "បាទសួស្តី 😄",
    isMe: true,
    time: '9:02 AM',
    isRead: true,
  ),
  _MockMsg(
    text: 'មានសង្សាឬនៅ borhter',
    isMe: false,
    time: '9:03 AM',
    reactions: ['❤️'],
  ),
  _MockMsg(
    text: 'អត់ទេ ប៉ុន្តែខ្ញុំកំពុងរៀនធ្វើ app chat មួយ 🤓',
    isMe: true,
    time: '9:05 AM',
    replyTo: 'ចុះ Sister មានសង្សាឬនៅ',
    isRead: true,
  ),
  _MockMsg(
    text: "ធ្វើសង្សាអូនហ្មងទៅចឹង😆",
    isMe: false,
    time: '9:06 AM',
    reactions: ['😮'],
  ),
  _MockMsg(
    text: "តោះចឹង លួចលេងក្នុងនិងកុំអោយសង្សាខ្ញុំដឹង😜",
    isMe: true,
    time: '9:10 AM',
    isRead: false,
  ),
];

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.otherUser});
  final UserProfile otherUser;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isInputEmpty = true;
  String? _replyingTo;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() {
      final empty = _inputCtrl.text.trim().isEmpty;
      if (empty != _isInputEmpty) setState(() => _isInputEmpty = empty);
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _setReply(String text) {
    setState(() => _replyingTo = text);
    HapticFeedback.lightImpact();
  }

  void _clearReply() => setState(() => _replyingTo = null);

  void _sendMessage() {
    if (_inputCtrl.text.trim().isEmpty) return;
    _inputCtrl.clear();
    _clearReply();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final name = widget.otherUser.name ?? 'User';

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      appBar: _AppBar(name: name, otherUser: widget.otherUser, t: t),
      body: Column(
        children: [
          Expanded(
            child: _MessagesList(
              messages: _mockMessages,
              t: t,
              onReply: _setReply,
              otherUser: widget.otherUser,
            ),
          ),
          if (_replyingTo != null)
            _ReplyBar(text: _replyingTo!, onClose: _clearReply, t: t),
          _InputBar(
            controller: _inputCtrl,
            isInputEmpty: _isInputEmpty,
            showEmoji: _showEmoji,
            t: t,
            onSend: _sendMessage,
            onAttach: () {},
            onEmojiToggle: () => setState(() => _showEmoji = !_showEmoji),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.name, required this.otherUser, required this.t});
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
          bottom: BorderSide(color: t.divider.withValues(alpha: 0.12), width: 1),
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
                              'Online',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: t.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _AppBarBtn(icon: Icons.videocam_rounded, color: t.primary, onTap: () {}),
                  _AppBarBtn(icon: Icons.call_rounded, color: t.primary, onTap: () {}),
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
  const _AppBarBtn({required this.icon, required this.color, required this.onTap});
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
// Messages list
// ─────────────────────────────────────────────────────────────────────────────

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.t,
    required this.onReply,
    required this.otherUser,
  });
  final List<_MockMsg> messages;
  final AppThemeExtension t;
  final void Function(String) onReply;
  final UserProfile otherUser;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      itemCount: messages.length + 1,
      itemBuilder: (context, i) {
        if (i == messages.length) return _DateChip(label: 'Today', t: t);
        final msg = messages[messages.length - 1 - i];
        return _BubbleWrapper(msg: msg, t: t, onReply: onReply, otherUser: otherUser);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleWrapper extends StatelessWidget {
  const _BubbleWrapper({required this.msg, required this.t, required this.onReply, required this.otherUser});
  final _MockMsg msg;
  final AppThemeExtension t;
  final void Function(String) onReply;
  final UserProfile otherUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment:
              msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isMe) ...[
              _OtherAvatar(t: t, user: otherUser),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (msg.replyTo != null)
                    _ReplyQuoteBubble(text: msg.replyTo!, isMe: msg.isMe, t: t),
                  _Bubble(msg: msg, t: t),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: t.hintText,
                        ),
                      ),
                      if (msg.isMe) ...[
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
                  if (msg.reactions.isNotEmpty)
                    _ReactionsChip(reactions: msg.reactions, t: t),
                ],
              ),
            ),
            if (msg.isMe) const SizedBox(width: 4),
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
        isMe: msg.isMe,
        t: t,
        onReply: () {
          Navigator.pop(context);
          onReply(msg.text);
        },
        onCopy: () {
          Navigator.pop(context);
          Clipboard.setData(ClipboardData(text: msg.text));
        },
        onDelete: () => Navigator.pop(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble variants
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, required this.t});
  final _MockMsg msg;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? t.primary : t.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.text,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          color: isMe ? Colors.white : t.bodyText,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ReplyQuoteBubble extends StatelessWidget {
  const _ReplyQuoteBubble({required this.text, required this.isMe, required this.t});
  final String text;
  final bool isMe;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.18)
            : t.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white.withValues(alpha: 0.7) : t.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          color: isMe ? Colors.white.withValues(alpha: 0.85) : t.hintText,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reactions chip
// ─────────────────────────────────────────────────────────────────────────────

class _ReactionsChip extends StatelessWidget {
  const _ReactionsChip({required this.reactions, required this.t});
  final List<String> reactions;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.divider.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(reactions.join(' '), style: const TextStyle(fontSize: 13)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Other user avatar
// ─────────────────────────────────────────────────────────────────────────────

class _OtherAvatar extends StatelessWidget {
  const _OtherAvatar({required this.t, required this.user});
  final AppThemeExtension t;
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    final initial = (user.name ?? 'U').isNotEmpty ? (user.name!)[0].toUpperCase() : 'U';
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(initial),
        ),
      );
    }
    return _fallback(initial);
  }

  Widget _fallback(String initial) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [t.primary.withValues(alpha: 0.7), t.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date chip
// ─────────────────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.t});
  final String label;
  final AppThemeExtension t;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: t.surfaceHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
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
// Reply bar above input
// ─────────────────────────────────────────────────────────────────────────────

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({required this.text, required this.onClose, required this.t});
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
                  'Replying to',
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
                  style: GoogleFonts.poppins(fontSize: 12.5, color: t.hintText),
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
    required this.t,
    required this.onSend,
    required this.onAttach,
    required this.onEmojiToggle,
  });
  final TextEditingController controller;
  final bool isInputEmpty;
  final bool showEmoji;
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
                border: Border.all(color: t.divider.withValues(alpha: 0.2)),
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
                        hintText: 'Type a message...',
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
              scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
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
                    onTap: onSend,
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
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.t, required this.size});
  final UserProfile user;
  final AppThemeExtension t;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl ?? '';
    final name = user.name ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: url.isEmpty
            ? LinearGradient(
                colors: [t.primary.withValues(alpha: 0.8), t.primary],
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
  const _InitialText(
      {required this.initial, required this.size, required this.color});
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
// Message options bottom sheet
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: emojis
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(e, style: const TextStyle(fontSize: 26)),
                          ),
                        ))
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
