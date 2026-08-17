import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
class NotificationService {
  static final NotificationService instance =
  NotificationService._internal();

  NotificationService._internal();
  Future<void> checkPendingNotifications() async {
    final pending =
    await _notifications.pendingNotificationRequests();

    debugPrint(
      'Pending notifications: ${pending.length}',
    );

    for (final notification in pending) {
      debugPrint(
        'Pending ID: ${notification.id}',
      );

      debugPrint(
        'Pending title: ${notification.title}',
      );
    }
  }
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();

    debugPrint(
      'All notifications cancelled.',
    );
  }
  Future<void> requestExactAlarmPermission() async {
    final androidImplementation =
    _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestExactAlarmsPermission();
  }
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Set timezone Việt Nam
    tz.setLocalLocation(
      tz.getLocation('Asia/Ho_Chi_Minh'),
    );

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    final androidImplementation =
    _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    await androidImplementation?.requestExactAlarmsPermission();

    const channel = AndroidNotificationChannel(
      'health_reminder_channel',
      'Health Reminders',
      description: 'Notifications for health reminders.',
      importance: Importance.high,
    );

    await androidImplementation?.createNotificationChannel(
      channel,
    );
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'health_reminder_channel',
      'Health Reminders',
      channelDescription:
      'Notifications for health reminders.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1,
      'Smart Health Tracker',
      'This is a test health reminder.',
      details,
    );
  }
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String type,
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'health_reminder_channel',
      'Health Reminders',
      channelDescription:
      'Notifications for health reminders.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    debugPrint(
      'Current time: $now',
    );

    debugPrint(
      'Scheduled time: $scheduledDate',
    );

    await _notifications.zonedSchedule(
      id,
      title,
      'Time to check your $type.',
      scheduledDate,
      details,
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }
  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }
}