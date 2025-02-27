import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smarttask/core/services/notification_service.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  group('NotificationService', () {
    late NotificationService notificationService;
    late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;

    setUp(() {
      mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      notificationService = NotificationService();
      notificationService.flutterLocalNotificationsPlugin =
          mockNotificationsPlugin;
    });

    test('initialize should setup notification plugin', () async {
      when(mockNotificationsPlugin.initialize(any,
              onDidReceiveNotificationResponse:
                  anyNamed('onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);

      when(mockNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(MockAndroidFlutterLocalNotificationsPlugin());

      final result = await notificationService.initialize();
      expect(result, true);

      verify(mockNotificationsPlugin.initialize(any,
              onDidReceiveNotificationResponse:
                  anyNamed('onDidReceiveNotificationResponse')))
          .called(1);
    });

    test('showCustomNotification should show notification', () async {
      when(mockNotificationsPlugin.show(any, any, any, any))
          .thenAnswer((_) async {});

      await notificationService.showCustomNotification(
        title: 'Test Title',
        body: 'Test Body',
      );

      verify(mockNotificationsPlugin.show(
        any,
        'Test Title',
        'Test Body',
        any,
      )).called(1);
    });

    test('scheduleTaskReminder should schedule notification', () async {
      when(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
      )).thenAnswer((_) async {});

      final scheduledTime = DateTime.now().add(const Duration(hours: 1));
      await notificationService.scheduleTaskReminder(
        'test-id',
        'Test Task',
        'Reminder for test task',
        scheduledTime,
      );

      verify(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      )).called(1);
    });

    test('requestNotificationsPermission should request permissions', () async {
      when(mockNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(MockAndroidFlutterLocalNotificationsPlugin());

      final result = await notificationService.requestNotificationsPermission();
      expect(result, true);
    });
  });
}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> requestPermission(
          bool? sound, bool? alert, bool? badge) async =>
      true;
}
