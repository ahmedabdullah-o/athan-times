//ExternalPackages
import 'package:app_settings/app_settings.dart';
import 'package:athan_times/services/permission_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/standalone.dart' as tz;
//LocalImports
import 'package:athan_times/core/data.dart';
import 'package:athan_times/core/logic.dart';

@pragma('vm:entry-point')
Future<void> notificationOnTap(NotificationResponse response) async {
  switch (response.payload) {
    case null:
      return;
    case 'navigateAndroidAppSettings':
      AppSettings.openAppSettings();
      break;
    default:
      throw Exception('The Invoked Payload Is Not Available');
  }
}

class SendNotifications extends NotificationService {
  ///Main SendNotification method
  ///Sends notifications based on info

  Future<void> _handler(
    NotificationInfo notificationInfo, {
    tz.TZDateTime? scheduledAt,
    DateTimeComponents? repeatInterval,
  }) async {
    return show(
      notificationInfo.id,
      scheduledDate: scheduledAt,
      repeatInterval: repeatInterval,
      androidScheduleMode:
          notificationInfo.category == AndroidNotificationCategory.alarm &&
                  await Permission.scheduleExactAlarm.isGranted
              ? AndroidScheduleMode.alarmClock
              : AndroidScheduleMode.inexact,
      channelId: notificationInfo.channelInfo.channelId,
      channelName: notificationInfo.channelInfo.channelName,
      channelDescription: notificationInfo.channelInfo.channelDesc,
      channelIcon: notificationInfo.channelInfo.channelIcon,
      importance: notificationInfo.importance,
      notificationSound: notificationInfo.notificationSound,
      title: notificationInfo.title,
      body: notificationInfo.body,
      payload: notificationInfo.payload,
      category: notificationInfo.category,
    );
  }

  Future<void> now(NotificationInfo notificationInfo) async {
    return await _handler(notificationInfo);
  }

  Future<void> scheduled(
    NotificationInfo notificationInfo,
    ChannelInfo channelInfo,
    tz.TZDateTime scheduledAt, {
    DateTimeComponents? repeatInterval,
  }) async {
    return await _handler(
      notificationInfo,
      scheduledAt: scheduledAt,
      repeatInterval: repeatInterval,
    );
  }
}

///flutter_local_notification.dart implementation
class NotificationService {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final permissionService = PermissionService();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  ///Crucial to run before using the class
  Future<void> initNotifications() async {
    await permissionService.allowNotifications();

    if (_isInitialized) {
      Debug.printMsg(
        'Notification service is already initialized, reinitialization cancelled!',
      );
      return;
    }
    Debug.printMsg('Initializing Notification service...');
    final androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: notificationOnTap,
    );
    _isInitialized = true;
  }

  ///Show notifications and alter every bit of data in it. NOTE: the property
  ///'isPersistent' is an abstracted version of the required settings to make
  ///a notification persistent
  Future<void> show(
    int id, {
    tz.TZDateTime? scheduledDate,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact,
    DateTimeComponents? repeatInterval,
    String channelId = 'general_channel',
    String channelName = 'General Channel',
    String? channelDescription,
    String? channelIcon,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
    AndroidNotificationSound? notificationSound,
    String? title,
    String? body,
    String? payload,
    AndroidNotificationCategory? category,
  }) async {
    PermissionService permissionService = PermissionService();
    await permissionService.androidAllowExactAlarm();
    NotificationDetails notificationDetailsNormal() {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: channelIcon,
          importance: importance,
          sound: notificationSound,
          category: category,
        ),
        iOS: DarwinNotificationDetails(),
      );
    }

    NotificationDetails notificationDetailsPersistent() {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: channelIcon,
          importance: importance,
          sound: notificationSound,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          silent: true,
        ),
        iOS: DarwinNotificationDetails(),
      );
    }

    return scheduledDate == null
        ? flutterLocalNotificationsPlugin.show(
          id,
          title,
          body,
          Check.isPersistentNotificationCategory(category)
              ? notificationDetailsPersistent()
              : notificationDetailsNormal(),
          payload: payload,
        )
        : flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetailsNormal(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: androidScheduleMode,
          matchDateTimeComponents: repeatInterval,
        );
  }
}
