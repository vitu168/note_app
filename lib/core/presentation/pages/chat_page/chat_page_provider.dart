import 'package:flutter/material.dart';
import 'package:note_app/core/models/chat_messenger_message.dart';
import 'package:note_app/core/models/user_profile.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';
import 'package:note_app/core/services/chat_messenger_api_service.dart';

/// Lightweight preview shown for each conversation in the chat list.
class ConversationPreview {
  const ConversationPreview({
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
    this.isLastMessageMine = false,
    this.isLastMessageRead = false,
    this.unreadCount = 0,
  });

  final UserProfile user;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isLastMessageMine;
  final bool isLastMessageRead; // If mine: did they read it? If theirs: did I read it?
  final int unreadCount;
}

class ChatPageProvider extends ChangeNotifier {
  final UserProfileApiService _userApi = UserProfileApiService();
  final ChatMessengerApiService _chatApi = ChatMessengerApiService();

  List<UserProfile> _allUsers = [];
  List<UserProfile> _filteredUsers = [];
  Map<String, ConversationPreview> _previews = {};
  int _unreadCount = 0;
  bool _loading = false;
  String _searchQuery = '';

  List<UserProfile> get users => _filteredUsers;
  bool get loading => _loading;
  int get unreadCount => _unreadCount;

  /// Returns the preview for a specific user (may be null if not loaded yet).
  ConversationPreview? previewFor(String userId) => _previews[userId];

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> loadUsers({String? currentUserId}) async {
    _loading = true;
    notifyListeners();
    try {
      _allUsers = await _userApi.getProfiles(pageSize: 100);
      _applyFilter();

      if (currentUserId != null) {
        // Load last-message previews and unread count in parallel
        await Future.wait([
          _loadPreviews(currentUserId),
          _loadUnreadCount(currentUserId),
        ]);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreviews(String currentUserId) async {
    try {
      // Fetch messages I sent AND messages I received in parallel
      final results = await Future.wait([
        _chatApi.getMessages(senderId: currentUserId, pageSize: 200),
        _chatApi.getMessages(receiverId: currentUserId, pageSize: 200),
      ]);

      // Combine both lists into a single flat list
      final allMessages = [...results[0].items, ...results[1].items];

      // Group by the "other user" ID → take the most recent message per conversation
      final Map<String, ChatMessengerMessage> latestByOtherUser = {};
      for (final msg in allMessages) {
        // The other user is whoever isn't me
        final otherUserId = msg.senderId == currentUserId
            ? msg.receiverId
            : msg.senderId;
        final existing = latestByOtherUser[otherUserId];
        if (existing == null || msg.createdAt.isAfter(existing.createdAt)) {
          latestByOtherUser[otherUserId] = msg;
        }
      }

      // Build preview map
      final previews = <String, ConversationPreview>{};
      for (final user in _allUsers) {
        final lastMsg = latestByOtherUser[user.id];
        previews[user.id] = ConversationPreview(
          user: user,
          lastMessage: lastMsg?.content,
          lastMessageTime: lastMsg?.createdAt,
          isLastMessageMine: lastMsg?.senderId == currentUserId,
          isLastMessageRead: lastMsg?.isRead ?? false,
          unreadCount: 0,
        );
      }
      _previews = previews;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadUnreadCount(String currentUserId) async {
    try {
      _unreadCount = await _chatApi.getUnreadCount(currentUserId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadUnreadCount(String receiverId) =>
      _loadUnreadCount(receiverId);

  // ── Filter ─────────────────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredUsers = List.of(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  Future<void> refresh({String? currentUserId}) =>
      loadUsers(currentUserId: currentUserId);
}
