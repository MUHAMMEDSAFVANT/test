import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'tasknest_channel';
  static const _channelName = 'TaskNest Alerts';
  static const _channelDesc = 'Task add / delete notifications';

  int _nextId = 0;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // Request Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showTaskAdded(String title) async {
    await _show(
      title: '✅ Task Added',
      body: '"$title" has been added to your list.',
    );
  }

  Future<void> showTaskDeleted(String title) async {
    await _show(
      title: '🗑️ Task Deleted',
      body: '"$title" has been removed.',
    );
  }

  Future<void> _show({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(_nextId++, title, body, details);
  }
}
