import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _isBudgetAlertsEnabled = true;

  bool get isBudgetAlertsEnabled => _isBudgetAlertsEnabled;

  Future<void> setBudgetAlertsEnabled(bool value) async {
    _isBudgetAlertsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budget_alerts_enabled', value);
  }

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isBudgetAlertsEnabled = prefs.getBool('budget_alerts_enabled') ?? true;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
    
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> scheduleDailyReminders() async {
    await clearDailyReminders();
    
    // 10 AM
    await _scheduleDaily(1, 'Log Your Expenses!', 'Pagi! Jangan lupa catat pengeluaran mu hari ini ya.', 10, 0);
    // 4 PM
    await _scheduleDaily(2, 'Afternoon Check-in', 'Sore! Sudah catat pengeluaran siang ini?', 16, 0);
    // 9 PM
    await _scheduleDaily(3, 'End of Day Summary', 'Malam! Yuk catat sisa pengeluaranmu hari ini.', 21, 0);
  }

  Future<void> clearDailyReminders() async {
    await _notificationsPlugin.cancel(id: 1);
    await _notificationsPlugin.cancel(id: 2);
    await _notificationsPlugin.cancel(id: 3);
  }

  Future<void> scheduleWeeklyReport() async {
    await _scheduleDaily(4, 'Weekly Report (Today)', 'Waktunya cek total pengeluaran Anda hari ini!', 22, 0);
  }

  Future<void> clearWeeklyReport() async {
    await _notificationsPlugin.cancel(id: 4);
  }

  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Reminders to log expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showBudgetAlertIfNeeded(double balance) async {
    if (!isBudgetAlertsEnabled) return;
    if (balance < 0) {
      // Show immediately
      await _notificationsPlugin.show(
        id: 99,
        title: 'Budget Alert',
        body: 'Uang minus! Total balance Anda saat ini kurang dari 0.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'budget_alerts',
            'Budget Alerts',
            channelDescription: 'Alerts for negative balance',
            importance: Importance.max,
            priority: Priority.high,
            color: Colors.red,
          ),
        ),
      );
      
      // Schedule another check at 10 PM
      await _scheduleDaily(100, 'Budget Alert', 'Uang minus! Segera periksa keuangan Anda.', 22, 0);
    } else {
      await _notificationsPlugin.cancel(id: 100);
    }
  }
}
