import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:note_app/core/models/note_info.dart';
import 'package:note_app/core/services/notification_store.dart';

class ReminderNotificationService {
  ReminderNotificationService._();
  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  static const _channelId = 'note_reminders';
  static const _channelName = 'Note Reminders';
  static const _channelDescription =
      'Alerts triggered at the time you set on a note.';

  static const int _kReminderIdOffset = 1000000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool? lastPermissionGranted;
  final Map<int, Timer> _inAppMirrorTimers = {};

  bool get isInitialized => _initialized;
  bool get isSupported => !kIsWeb;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;

    tzdata.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fallback: leave default UTC. Reminders still fire, just shifted in
      // edge cases where the device timezone isn't resolvable.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onResponse,
    );

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      lastPermissionGranted = await android?.requestNotificationsPermission();
    }
  }
  Future<bool?> ensurePermission() async {
    if (kIsWeb) return false;
    if (!_initialized) await init();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      lastPermissionGranted =
          await android?.requestNotificationsPermission() ?? false;
      return lastPermissionGranted;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final ok = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      lastPermissionGranted = ok;
      return ok;
    }
    return true;
  }

  void _onResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      NotificationStore.instance.add(
        title: 'Reminder',
        body: payload,
        senderId: null,
      );
    }
  }

  int _idFor(int noteId) => _kReminderIdOffset + noteId;

  NotificationDetails _details(String body) => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  void _scheduleWebMirror(NoteInfo note, DateTime when, String title, String body) {
    final delay = when.difference(DateTime.now());
    if (delay.isNegative) return;
    _inAppMirrorTimers[note.id]?.cancel();
    _inAppMirrorTimers[note.id] = Timer(delay, () {
      _inAppMirrorTimers.remove(note.id);
      NotificationStore.instance.add(
        title: title,
        body: body,
        senderId: null,
      );
    });
  }

  void _scheduleInAppMirror(int noteId, DateTime when, String title, String body) {
    final delay = when.difference(DateTime.now());
    if (delay.isNegative || delay > const Duration(hours: 12)) return;
    _inAppMirrorTimers[noteId]?.cancel();
    _inAppMirrorTimers[noteId] = Timer(delay, () {
      _inAppMirrorTimers.remove(noteId);
      NotificationStore.instance.add(
        title: title,
        body: body,
        senderId: null,
      );
    });
  }

  Future<void> scheduleForNote(NoteInfo note) async {
    final id = _idFor(note.id);
    _inAppMirrorTimers.remove(note.id)?.cancel();

    final when = note.reminder;
    if (when == null) return;
    if (!when.isAfter(DateTime.now())) return;

    final title = note.name?.trim().isNotEmpty == true
        ? note.name!
        : 'Note reminder';
    final body = (note.description?.trim().isNotEmpty == true)
        ? note.description!
        : 'Reminder';

    if (kIsWeb) {
      _scheduleWebMirror(note, when, title, body);
      return;
    }
    if (!_initialized) return;
    await _plugin.cancel(id);

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        _details(body),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: body,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzWhen,
          _details(body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: body,
        );
      } else {
        rethrow;
      }
    }

    _scheduleInAppMirror(note.id, when, title, body);
  }

  Future<void> cancelForNote(int noteId) async {
    _inAppMirrorTimers.remove(noteId)?.cancel();
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(_idFor(noteId));
  }

  Future<void> rescheduleAll(Iterable<NoteInfo> notes) async {
    for (final n in notes) {
      if (n.reminder != null && n.reminder!.isAfter(DateTime.now())) {
        await scheduleForNote(n);
      }
    }
  }

  Future<List<PendingNotificationRequest>> pending() async {
    if (kIsWeb || !_initialized) return const [];
    return _plugin.pendingNotificationRequests();
  }
}
