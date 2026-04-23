import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
        
    // Also request exact alarm permissions for Alarm package if necessary
  }

  static Future<void> schedulePrayerNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    // Ignore times that have already passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/audio/adhan.mp3',
      loopAudio: false,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'إيقاف الأذان',
      ),
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAllNotifications() async {
    await Alarm.stopAll();
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
