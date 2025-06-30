import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:purity_path/data/services/permissions_service.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/logo'); // Use your app's icon
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await PermissionService.requestNotificationPermission();
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<bool> isNotificationPermissionGranted() async {
    if (Platform.isAndroid) {
      return await PermissionService.isNotificationPermissionGranted();
    } else if (Platform.isIOS) {
      final iosSettings = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return iosSettings?.isAlertEnabled ?? false;
    }
    return false;
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'n_islam_channel',
      'N Islam Notifications',
      channelDescription: 'Notifications for N Islam app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}