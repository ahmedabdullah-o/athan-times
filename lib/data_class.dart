import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services.dart';

abstract final class AppColors {
  static Color black33 = Color.fromARGB(255, 33, 33, 33),
      black55 = Color.fromARGB(255, 55, 55, 55),
      whiteSmoke = Color.fromARGB(255, 255, 255, 248),
      greySmoke = Color.fromARGB(255, 233, 233, 218);
}

abstract final class AppFonts {
  static TextStyle dongleBlack = TextStyle(
        fontFamily: "Dongle",
        fontSize: 40,
        color: AppColors.black55,
      ),
      dongleWhiteSmoke = TextStyle(
        fontFamily: "Dongle",
        fontSize: 40,
        color: AppColors.whiteSmoke,
      );
}

abstract final class AppNotifications {
  static Future<void> athanNotification({
    int id = 0,
    String title = 'Pray',
    String body = 'It\'s praying time :)',
    AndroidNotificationSound notificationSound =
        const RawResourceAndroidNotificationSound('notification_sound'),
    String? payload,
  }) async {
    return NotificationService.showNotification(
      channelId: 'prayer_sound',
      channelName: 'Prayer Sound',
      channelDescription: 'The notification sent at prayer time.',
      channelIcon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.max,
      notificationSound: notificationSound,
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }
}
