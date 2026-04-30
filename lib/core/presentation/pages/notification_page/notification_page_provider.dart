import 'package:flutter/material.dart';
import 'package:note_app/core/models/notification_item.dart';
import 'package:note_app/core/services/notification_store.dart';

class NotificationPageProvider extends ChangeNotifier {
  NotificationPageProvider() {
    // Mirror the store so the page rebuilds when new notifications arrive
    NotificationStore.instance.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => notifyListeners();

  List<NotificationItem> get items => NotificationStore.instance.items;
  int get unreadCount => NotificationStore.instance.unreadCount;

  void markRead(int id) => NotificationStore.instance.markRead(id);

  void markAllRead() => NotificationStore.instance.markAllRead();

  void remove(int id) => NotificationStore.instance.remove(id);

  void clear() => NotificationStore.instance.clear();

  @override
  void dispose() {
    NotificationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }
}
