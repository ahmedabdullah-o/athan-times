import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract final class CoreColors {
  static const Color black33 = Color.fromARGB(255, 33, 33, 33),
      black55 = Color.fromARGB(255, 55, 55, 55),
      whiteSmoke = Color.fromARGB(255, 255, 255, 248),
      greySmoke = Color.fromARGB(255, 233, 233, 218);
}

abstract final class CoreFonts {
  static const TextStyle dongleBlack = TextStyle(
        fontFamily: "Dongle",
        color: CoreColors.black55,
      ),
      dongleWhiteSmoke = TextStyle(
        fontFamily: "Dongle",
        fontSize: 25,
        color: CoreColors.whiteSmoke,
      );
}

enum CoreNotificationType {
  alarm,
  persistent,
  general,
}

class CoreChannelInfo {
  final String channelId;
  final String channelName;
  final String channelDesc;
  final String channelIcon;
  final Importance importance;
  final Priority priority;
  final AndroidNotificationSound? notificationSound;
  final bool isPersistent;

  CoreChannelInfo({
    required this.channelId,
    required this.channelName,
    required this.channelDesc,
    required this.channelIcon,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
    this.notificationSound,
    this.isPersistent = false,
  });

  static CoreChannelInfo getFromType(CoreNotificationType type) {
    // Since we're using enum types, we don't need to define the default return value
    switch (type) {
      case CoreNotificationType.alarm:
        return CoreChannelInfo(
          channelId: 'athan_notification',
          channelName: 'Athan Notification',
          channelDesc: 'alarm-like notification sent at prayer time',
          channelIcon: '@mipmap/ic_launcher',
        );
      case CoreNotificationType.persistent:
        return CoreChannelInfo(
          channelId: 'persistent_notification',
          channelName: 'Persistent Notification',
          channelDesc:
              'persistent notification to show a certain state of the app',
          channelIcon: '@mipmap/ic_launcher',
          isPersistent: true,
        );
      case CoreNotificationType.general:
        return CoreChannelInfo(
          channelId: 'general_notification',
          channelName: 'General Notification',
          channelDesc: 'General notification',
          channelIcon: '@mipmap/ic_launcher',
        );
    }
  }
}

class CoreNotificationInfo {
  final int id;
  final String title;
  final String? body;
  final AndroidNotificationSound? notificationSound;
  final String? payload;

  CoreNotificationInfo({
    required this.id,
    required this.title,
    this.body,
    this.notificationSound,
    this.payload,
  });
}
