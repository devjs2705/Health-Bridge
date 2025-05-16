import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  static Future<void> init() async {
    // Initialize timezones (needed for scheduled notifications)
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ Request permission for Android 13+ (API 33+)
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestPermission();
    }
  }


  Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required TimeOfDay timeOfDay,
    required List<int> weekdays,
    required bool afterMeal,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'med_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Channel for medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('medicine_reminder_notification_tune'), // optional custom sound, add file in android/res/raw/reminder_tone.mp3
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);

    for (int weekday in weekdays) {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id + weekday, // unique ID per day
        'Medicine Reminder',
        '$medicineName – ${afterMeal ? "After" : "Before"} meal',
        scheduledDate,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
