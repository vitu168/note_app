import 'package:flutter/material.dart';
import 'package:note_app/core/models/notification_item.dart';

/// In-memory store for all notifications received during the current session.
/// Singleton ChangeNotifier — register once in main.dart and listen app-wide.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<NotificationItem> _items = [];
  int _nextId = 1;

  /// All notifications, newest first.
  List<NotificationItem> get items =>
      List.unmodifiable(_items.reversed.toList());

  /// Number of unread notifications.
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Add a new notification (called by ChatNotificationService).
  void add({
    required String title,
    required String body,
    String? senderId,
  }) {
    _items.add(NotificationItem(
      id: _nextId++,
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      senderId: senderId,
    ));
    notifyListeners();
  }

  /// Mark a single notification as read.
  void markRead(int id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx >= 0 && !_items[idx].isRead) {
      _items[idx] = _items[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read.
  void markAllRead() {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Remove a single notification.
  void remove(int id) {
    final before = _items.length;
    _items.removeWhere((n) => n.id == id);
    if (_items.length != before) notifyListeners();
  }

  /// Clear all notifications.
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
