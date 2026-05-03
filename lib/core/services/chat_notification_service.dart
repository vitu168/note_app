import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:note_app/core/services/notification_store.dart';

// ─── Background FCM handler ── must be top-level ──────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this is called on iOS/Android.
  // Nothing extra needed — the OS shows the notification automatically from FCM.
}

// ─── Notification service singleton ───────────────────────────────────────────
class ChatNotificationService {
  ChatNotificationService._();
  static final ChatNotificationService instance = ChatNotificationService._();

  static const _channelId = 'chat_messages';
  static const _channelName = 'Chat Messages';

  final _plugin = FlutterLocalNotificationsPlugin();

  /// True while the user is actively viewing a specific chat conversation.
  /// Set this to avoid showing in-app banners when the user is already reading.
  String? activeChatUserId;

  Future<void> init() async {
    // Notifications only supported on mobile platforms
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // Create Android high-importance channel
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
    }

    // Show foreground FCM notifications via local plugin
    FirebaseMessaging.onMessage.listen(_onForegroundFcm);

    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void _onForegroundFcm(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    final senderId = message.data['senderId']?.toString();
    showChatNotification(
      id: message.hashCode,
      senderName: n.title ?? 'New message',
      content: n.body ?? '',
      senderId: senderId,
    );
  }

  /// Show a local in-app notification for a chat message.
  /// Pass [senderId] so we can suppress it if the user is already in that chat.
  Future<void> showChatNotification({
    required int id,
    required String senderName,
    required String content,
    required String? senderId,
  }) async {
    // Don't notify while the user is actively reading this conversation
    if (senderId != null && activeChatUserId == senderId) return;

    // Always record into the in-app notification store so the bell badge and
    // notification page reflect the message even on web (where the local
    // plugin is unavailable).
    NotificationStore.instance.add(
      title: senderName,
      body: content,
      senderId: senderId,
    );

    // Local OS notifications only on mobile.
    if (kIsWeb) return;

    await _plugin.show(
      id,
      senderName,
      content,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(content),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
