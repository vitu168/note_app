import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_app/core/models/chat_messenger_message.dart';
import 'package:note_app/core/models/message_type.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/chat_messenger_api_service.dart';
import 'package:note_app/core/services/chat_notification_service.dart';

class ChatDetailProvider extends ChangeNotifier {
  ChatDetailProvider({required this.otherUser, required this.currentUserId});

  final UserProfile otherUser;
  final String currentUserId;

  final ChatMessengerApiService _api = ChatMessengerApiService();

  List<ChatMessengerMessage> _messages = [];
  // Optimistic (in-flight) message shown immediately after tapping send
  String? _optimisticContent;
  bool _optimisticFailed = false;

  bool _loading = true;
  bool _sending = false;
  String? _lastError;
  Timer? _pollTimer;
  bool _disposed = false; // Flag to prevent notifyListeners after dispose

  // Last message ID received from the other user — used to detect truly new messages
  int _lastSeenOtherMsgId = 0;

  List<ChatMessengerMessage> get messages => _messages;
  bool get loading => _loading;
  bool get sending => _sending;
  String? get error => _lastError;
  String? get optimisticContent => _optimisticContent;
  bool get optimisticFailed => _optimisticFailed;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_disposed) return;
    _loading = true;
    _lastError = null;
    if (!_disposed) notifyListeners();

    print('🔵 Chat init: currentUserId=$currentUserId, otherUser.id=${otherUser.id}');

    // Validate IDs
    if (currentUserId.isEmpty) {
      _lastError = 'Error: Your user ID is empty. Please log out and login again.';
      _loading = false;
      if (!_disposed) notifyListeners();
      return;
    }

    // Suppress notifications while the user is actively viewing this chat
    ChatNotificationService.instance.activeChatUserId = otherUser.id;

    try {
      await _fetchMessages();
      if (!_disposed) _startPolling();
    } catch (e) {
      if (!_disposed) {
        _lastError = e.toString();
        print('❌ Init error: $e');
      }
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void _startPolling() {
    if (_disposed) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!_disposed) {
        try {
          await _fetchMessages(silent: true);
        } catch (_) {}
      }
    });
  }

  // ── Core fetch ─────────────────────────────────────────────────────────────

  Future<void> _fetchMessages({bool silent = false}) async {
    if (_disposed) return;

    // Single API call — backend returns the full conversation when both IDs are provided
    final result = await _api.getMessages(
      senderId: currentUserId,
      receiverId: otherUser.id,
    );

    if (_disposed) return;

    final combined = List<ChatMessengerMessage>.from(result.items)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Messages from the other user, for notification + mark-read logic
    final theirSent =
        combined.where((m) => m.senderId == otherUser.id).toList();

    // Detect new messages from the other user → trigger in-app notification
    if (_lastSeenOtherMsgId > 0 && theirSent.isNotEmpty) {
      final newMsgs =
          theirSent.where((m) => m.id > _lastSeenOtherMsgId).toList();
      for (final msg in newMsgs) {
        ChatNotificationService.instance.showChatNotification(
          id: msg.id,
          senderName: otherUser.name ?? 'Message',
          content: msg.content,
          senderId: otherUser.id,
        );
      }
    }

    // Update last seen ID + mark new received messages as read
    if (theirSent.isNotEmpty) {
      final maxId =
          theirSent.map((m) => m.id).reduce((a, b) => a > b ? a : b);
      if (maxId > _lastSeenOtherMsgId) {
        _lastSeenOtherMsgId = maxId;
        final unread = theirSent.where((m) => !m.isRead).toList();
        _markReceivedRead(unread);
      }
    } else if (_lastSeenOtherMsgId == 0 && theirSent.isEmpty) {
      _lastSeenOtherMsgId = -1; // sentinel: no messages exist yet
    }

    // Only rebuild if the message list actually changed (compare last ID + count)
    final prevLastId = _messages.isNotEmpty ? _messages.last.id : -1;
    final newLastId = combined.isNotEmpty ? combined.last.id : -1;
    final changed =
        combined.length != _messages.length || newLastId != prevLastId;

    _messages = combined;

    if (!silent || changed) {
      if (!_disposed) notifyListeners();
    }
  }

  void _markReceivedRead(List<ChatMessengerMessage> unread) {
    for (final msg in unread) {
      _api
          .updateMessage(
            msg.id,
            senderId: msg.senderId,
            receiverId: msg.receiverId,
            content: msg.content,
            messageType: 'TextChat',
            isRead: true,
          )
          .ignore();
    }
  }

  // ── Send ───────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (_disposed) return;
    if (currentUserId.isEmpty) {
      _lastError = 'Error: Your user ID is not set. Please log out and login again.';
      if (!_disposed) notifyListeners();
      return;
    }
    if (otherUser.id.isEmpty) {
      _lastError = 'Error: Recipient user ID is not set.';
      if (!_disposed) notifyListeners();
      return;
    }

    // Detect message type based on content
    final messageType = MessageType.detectFromContent(trimmed);

    // Show optimistic bubble immediately — feels instant like FB Messenger
    _optimisticContent = trimmed;
    _optimisticFailed = false;
    _sending = true;
    _lastError = null;
    if (!_disposed) notifyListeners();

    try {
      final sent = await _api.sendMessage(
        senderId: currentUserId,
        receiverId: otherUser.id,
        content: trimmed,
        messageType: messageType.apiValue,
      );
      if (!_disposed) {
        _messages = [..._messages, sent];
        _optimisticContent = null;
        _optimisticFailed = false;
        _lastError = null;
      }
    } catch (e) {
      if (!_disposed) {
        _optimisticFailed = true;
        _lastError = 'Failed to send: ${e.toString()}';
        print('❌ Send message error: $e');
      }
    } finally {
      if (!_disposed) {
        _sending = false;
        notifyListeners();
      }
    }
  }

  Future<void> retryFailedSend() async {
    final content = _optimisticContent;
    if (content == null || _disposed) return;
    _optimisticFailed = false;
    if (!_disposed) notifyListeners();
    await sendMessage(content);
  }

  void dismissFailedSend() {
    if (_disposed) return;
    _optimisticContent = null;
    _optimisticFailed = false;
    if (!_disposed) notifyListeners();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteMessage(int id) async {
    if (_disposed) return;
    // Remove optimistically, restore on error
    final backup = List<ChatMessengerMessage>.from(_messages);
    _messages = _messages.where((m) => m.id != id).toList();
    if (!_disposed) notifyListeners();
    try {
      await _api.deleteMessage(id);
    } catch (_) {
      if (!_disposed) {
        _messages = backup;
        notifyListeners();
      }
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> updateMessage(int id,
      {String? content, bool? isRead}) async {
    if (_disposed) return;
    final original = _messages.firstWhere((m) => m.id == id);
    final updated = await _api.updateMessage(
      id,
      senderId: original.senderId,
      receiverId: original.receiverId,
      content: content ?? original.content,
      messageType: original.messageType,
      isRead: isRead ?? original.isRead,
    );
    if (!_disposed) {
      _messages = _messages.map((m) => m.id == id ? updated : m).toList();
      notifyListeners();
    }
  }

  // ── Unread count ───────────────────────────────────────────────────────────

  Future<int> getUnreadCount() => _api.getUnreadCount(currentUserId);

  // ── Manual refresh ─────────────────────────────────────────────────────────

  Future<void> refresh() async {
    try {
      await _fetchMessages();
    } catch (_) {}
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    if (ChatNotificationService.instance.activeChatUserId == otherUser.id) {
      ChatNotificationService.instance.activeChatUserId = null;
    }
    super.dispose();
  }
}
