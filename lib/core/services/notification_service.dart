import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> _selectNotificationSubject =
      BehaviorSubject<String?>();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Stream<String?> get selectNotificationStream =>
      _selectNotificationSubject.stream;

  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Initialize local notifications
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          _selectNotificationSubject.add(details.payload);
        },
      );

      // Create the notification channel
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_notifications',
        'Task Notifications',
        description: 'Notifications for task management',
        importance: Importance.high,
        playSound: true,
        showBadge: true,
        enableVibration: true,
      );

      // Create the Android-specific notification channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Handle FCM messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle FCM messages when app is in background and user taps notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Initialize timezone
      tz.initializeTimeZones();

      // Get the local timezone offset
      final now = DateTime.now();
      final timeZoneOffset = now.timeZoneOffset;
      final hours = timeZoneOffset.inHours;
      final minutes = (timeZoneOffset.inMinutes % 60).abs();
      final offsetName =
          '${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      final locationName = 'Etc/GMT$offsetName';

      try {
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (e) {
        // Fallback to UTC if the timezone is not found
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['route'] != null) {
      _selectNotificationSubject.add(message.data['route']);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Custom notification preferences
  Future<void> updateNotificationPreferences({
    required bool taskDeadlines,
    required bool newAssignments,
    required bool teamUpdates,
    required bool performanceMetrics,
  }) async {
    if (taskDeadlines)
      await subscribeToTopic('task_deadlines');
    else
      await unsubscribeFromTopic('task_deadlines');

    if (newAssignments)
      await subscribeToTopic('new_assignments');
    else
      await unsubscribeFromTopic('new_assignments');

    if (teamUpdates)
      await subscribeToTopic('team_updates');
    else
      await unsubscribeFromTopic('team_updates');

    if (performanceMetrics)
      await subscribeToTopic('performance_metrics');
    else
      await unsubscribeFromTopic('performance_metrics');
  }

  Future<void> scheduleTaskReminder(
    String taskId,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      print('Cannot schedule notification for past time');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.zonedSchedule(
      taskId.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await _localNotifications.cancel(taskId.hashCode);
  }

  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String channelId = 'task_notifications',
    String channelName = 'Task Notifications',
    String channelDescription = 'Notifications for task management',
  }) async {
    try {
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
        showBadge: true,
        enableVibration: true,
      );

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        channelShowBadge: true,
        autoCancel: true,
      );

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _localNotifications.show(
        id,
        title,
        body,
        details,
      );
      print('Notification shown successfully: $title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
