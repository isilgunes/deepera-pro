import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // If Web, maybe just return or do minimal init? 
    // FlutterLocalNotificationsPlugin supports web, but let's stick to "Mobile Only" features for now
    // unless user requested web notifications.
    // The instructions said "Code Guards" for things that don't work.
    
    if (kIsWeb) return; 

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Check/Request Exact Alarm Permission on Android 12+
    await requestExactAlarmPermission();

    // Explicitly create the channel for Android to ensure settings apply
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'pomodoro_timer_final_v1', // NEW ID
          'Aktif Sayaç', // NEW NAME
          description: 'Shows active timer countdown',
          importance: Importance.max, // High importance for lock screen
          playSound: false,
          enableVibration: false,
          showBadge: true,
        ),
      );
    }
  }
  
  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      debugPrint("Requesting Schedule Exact Alarm Permission...");
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskReminder(DateTime taskTime, String title) async {
    // Get Local Location (requires initialization in main, which we did)
    // final locations = tz.timeZoneDatabase.locations; 
    // We assume tz.local is set correctly by initializeTimeZones()
    final location = tz.local; 

    // Calculate trigger time (5 mins before)
    final scheduledDate = taskTime.subtract(const Duration(minutes: 5));
    final now = DateTime.now();

    if (scheduledDate.isBefore(now)) {
       // If time has passed or is very close, show IMMEDIATELY
       await _notificationsPlugin.show(
         taskTime.hashCode,
         "Görev Hatırlatıcı ⏳",
         "'$title' görevi için zaman geldi/geçiyor!",
         const NotificationDetails(
           android: AndroidNotificationDetails(
             'task_reminders_v1', 
             'Görev Hatırlatıcıları',
             importance: Importance.max, 
             priority: Priority.high,
           ),
         ),
       );
    } else {
       // Schedule using TZDateTime
       await _notificationsPlugin.zonedSchedule(
         taskTime.hashCode,
         "Görev Hatırlatıcı ⏳",
         "'$title' görevine 5 dakika kaldı. Hazır mısın?",
         tz.TZDateTime.from(scheduledDate, location), // CRITICAL FIX
         const NotificationDetails(
           android: AndroidNotificationDetails(
             'task_reminders_v1', 
             'Görev Hatırlatıcıları',
             importance: Importance.max, 
             priority: Priority.high,
           ),
         ),
         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
       );
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Notifications',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> showTimerNotification(int remainingSeconds, String modeTitle) async {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_timer_final_v1', // NEW ID to force update
      'Aktif Sayaç', // NEW NAME
      channelDescription: 'Shows active timer countdown',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true, 
      playSound: false, // Silent updates
      enableVibration: false,
      showWhen: false,
      usesChronometer: false,
      visibility: NotificationVisibility.public, // VISIBLE ON LOCK SCREEN
      category: AndroidNotificationCategory.status, // Correct Category
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      999, 
      modeTitle, 
      '$timeString kaldı',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelTimerNotification() async {
    await _notificationsPlugin.cancel(999);
  }

  Future<void> scheduleDailyQuote() async {
    final quotes = [
      "Başarı, pes etmeyenlerindir.",
      "Bugün harika işler başaracaksın!",
      "Odaklan ve hedefine ulaş.",
      "Zaman en değerli hazinedir, onu iyi kullan.",
      "Küçük adımlar büyük başarılar getirir.",
      "Disiplin, hedeflerle başarı arasındaki köprüdür.",
      "Kendine inan, yapabilirsin!",
      "Her gün yeni bir başlangıçtır.",
      "Yorgun olduğunda dinlen, vazgeçme.",
      "Gelecek, bugünden hazırlananlara aittir.",
    ];
    
    // Pick a random quote
    final quote = (quotes..shuffle()).first;

    // Schedule for 9:00 AM tomorrow (or today if earlier)
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      888, // Quote ID
      'Günün Sözü 💡',
      quote,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quotes_channel',
          'Motivational Quotes',
          channelDescription: 'Daily motivation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
