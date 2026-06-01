import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'cropguard_alerts';
  static const String _channelName = 'CropGuard Alerts';
  static const String _channelDesc =
      'Notifications for disease risks and scan reminders';

  static Future<void> init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showRiskAlert({
    required String title,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      1,
      title,
      message,
      notificationDetails,
    );
  }

  static Future<void> showScanReminder({
    required String title,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2,
      title,
      message,
      notificationDetails,
    );
  }
}
