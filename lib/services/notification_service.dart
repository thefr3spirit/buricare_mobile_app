import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Call once at app startup.
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create a channel so notifications on Android O+ have a category
    const channel = AndroidNotificationChannel(
      'alerts', 
      'Alerts', 
      description: 'Vital‑sign out‑of‑range alerts',
      importance: Importance.max,
    );
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  /// Show a simple alert notification.
  static Future<void> showAlert(String message) {
    return _plugin.show(
      0,
      'BuriCare Alert',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alerts',
          'Alerts',
          channelDescription: 'Vital‑sign out‑of‑range alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
