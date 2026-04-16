import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/core/models/chat_message.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/chat_service.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';

class ChatDetailProvider extends ChangeNotifier {
  final UserProfile otherUser;
  ChatDetailProvider({required this.otherUser});

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _hasMore = true;
  String? _conversationId;
  RealtimeChannel? _channel;

  String? _replyTo; // message id being replied to
  String? _replyToText;
  String? _replyToSenderName;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;
  bool get sending => _sending;
  bool get hasMore => _hasMore;
  String? get conversationId => _conversationId;
  String? get replyTo => _replyTo;
  String? get replyToText => _replyToText;
  String? get replyToSenderName => _replyToSenderName;

  String get currentUserId => AuthService.currentUser()?.id ?? '';

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      _conversationId = await ChatService.getOrCreateConversation(
        currentUserId,
        otherUser.id,
      );
      await _loadMessages();
      _subscribeRealtime();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMessages() async {
    final msgs = await ChatService.loadMessages(_conversationId!);
    _messages = msgs.reversed.toList(); // oldest first for display
    await ChatService.markRead(_conversationId!, currentUserId);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _messages.isEmpty || _conversationId == null) return;
    final older = await ChatService.loadMessages(
      _conversationId!,
      limit: 30,
      beforeId: _messages.first.id,
    );
    if (older.length < 30) _hasMore = false;
    _messages = [...older.reversed, ..._messages];
    notifyListeners();
  }

  void _subscribeRealtime() {
    if (_conversationId == null) return;
    _channel = ChatService.subscribeToMessages(
      _conversationId!,
      (msg) {
        // Avoid duplicate if we just sent it
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages = [..._messages, msg];
          notifyListeners();
          if (msg.senderId != currentUserId) {
            ChatService.markRead(_conversationId!, currentUserId);
          }
        }
      },
      (updated) {
        final idx = _messages.indexWhere((m) => m.id == updated.id);
        if (idx >= 0) {
          _messages = List.from(_messages)..[idx] = updated;
          notifyListeners();
        }
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _conversationId == null) return;
    _sending = true;
    notifyListeners();

    // Optimistic insert
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: _conversationId!,
      senderId: currentUserId,
      text: text.trim(),
      status: MessageStatus.sending,
      replyToId: _replyTo,
      replyToText: _replyToText,
      replyToSenderName: _replyToSenderName,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, optimistic];
    clearReply();
    notifyListeners();

    try {
      final sent = await ChatService.sendMessage(
        conversationId: _conversationId!,
        senderId: currentUserId,
        text: text.trim(),
        replyToId: optimistic.replyToId,
        replyToText: optimistic.replyToText,
        replyToSenderName: optimistic.replyToSenderName,
      );
      // Replace optimistic with real message
      _messages = _messages.map((m) => m.id == tempId ? sent : m).toList();
    } catch (_) {
      // Mark as failed
      _messages = _messages
          .map((m) => m.id == tempId
              ? m.copyWith(status: MessageStatus.failed)
              : m)
          .toList();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    await ChatService.deleteMessage(messageId);
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx >= 0) {
      _messages = List.from(_messages)
        ..[idx] = _messages[idx].copyWith(isDeleted: true, text: '');
      notifyListeners();
    }
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    if (_conversationId == null) return;
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    final msg = _messages[idx];
    final updated = List<MessageReaction>.from(msg.reactions);
    final existing = updated.indexWhere(
      (r) => r.userId == currentUserId && r.emoji == emoji,
    );
    if (existing >= 0) {
      updated.removeAt(existing);
    } else {
      updated.removeWhere((r) => r.userId == currentUserId);
      updated.add(MessageReaction(userId: currentUserId, emoji: emoji));
    }
    _messages = List.from(_messages)..[idx] = msg.copyWith(reactions: updated);
    notifyListeners();
    await ChatService.toggleReaction(
      messageId: messageId,
      conversationId: _conversationId!,
      userId: currentUserId,
      emoji: emoji,
      currentReactions: msg.reactions,
    );
  }

  void setReply(ChatMessage msg, String senderName) {
    _replyTo = msg.id;
    _replyToText = msg.text ?? '📷 Photo';
    _replyToSenderName = senderName;
    notifyListeners();
  }

  void clearReply() {
    _replyTo = null;
    _replyToText = null;
    _replyToSenderName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_channel != null) ChatService.unsubscribe(_channel!);
    super.dispose();
  }
}
