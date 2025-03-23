import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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

class ChannelInfo {
  final String channelId;
  final String channelName;
  final String channelDesc;
  final String channelIcon;
  ChannelInfo(
    this.channelId,
    this.channelName,
    this.channelDesc, {
    this.channelIcon = '@mipmap/ic_launcher',
  });
}

class NotificationInfo {
  final int id;
  final String title;
  final String? body;
  final AndroidNotificationCategory? category;
  final AndroidNotificationSound? notificationSound;
  final String? payload;
  final ChannelInfo channelInfo;
  final Importance importance;

  NotificationInfo(
    this.id,
    this.title,
    this.body,
    this.channelInfo, {
    this.category,
    this.notificationSound,
    this.payload,
    this.importance = Importance.defaultImportance,
  });

  static NotificationInfo formCategory(
    int id,
    String title,
    String body,
    AndroidNotificationCategory category, {
    AndroidNotificationSound? notificationSound,
    String? payload,
  }) {
    String channelId, channelName, channelDesc, categoryName = category.name;
    channelId = categoryName;
    channelName = categoryName[0].toUpperCase() + categoryName.substring(1);
    channelDesc =
        "The notification channel used to send $channelName notifications";
    return NotificationInfo(
      id,
      title,
      body,
      ChannelInfo(channelId, channelName, channelDesc),
      notificationSound: notificationSound,
      payload: payload,
      category: category,
      importance: importanceFromCategory(category),
    );
  }

  static Importance importanceFromCategory(
    AndroidNotificationCategory category,
  ) {
    switch (category) {
      // Critical notifications – require immediate attention
      case AndroidNotificationCategory.alarm:
      case AndroidNotificationCategory.call:
      case AndroidNotificationCategory.error:
      case AndroidNotificationCategory.missedCall:
        return Importance.max;

      // High priority notifications – important alerts
      case AndroidNotificationCategory.message:
      case AndroidNotificationCategory.reminder:
      case AndroidNotificationCategory.event:
      case AndroidNotificationCategory.navigation:
      case AndroidNotificationCategory.transport:
      case AndroidNotificationCategory.workout:
        return Importance.high;

      // Default importance for standard notifications
      case AndroidNotificationCategory.email:
      case AndroidNotificationCategory.locationSharing:
      case AndroidNotificationCategory.progress:
      case AndroidNotificationCategory.recommendation:
      case AndroidNotificationCategory.social:
      case AndroidNotificationCategory.stopwatch:
      case AndroidNotificationCategory.system:
        return Importance.defaultImportance;

      // Lower priority notifications – less intrusive
      case AndroidNotificationCategory.promo:
      case AndroidNotificationCategory.status:
        return Importance.low;

      // Background or silent notifications
      case AndroidNotificationCategory.service:
        return Importance.min;
    }
  }

  static Future<AndroidScheduleMode> scheduleModeFromCategory(
    AndroidNotificationCategory category,
  ) async {
    switch (category) {
      // Use alarmClock mode if permission is granted, fallback to exact or inexact
      case AndroidNotificationCategory.alarm:
        if (await Permission.scheduleExactAlarm.isGranted) {
          return AndroidScheduleMode.alarmClock;
        }
        return AndroidScheduleMode.inexact;

      // Time-sensitive actions: prefer exact, fallback to inexact
      case AndroidNotificationCategory.call:
      case AndroidNotificationCategory.error:
      case AndroidNotificationCategory.missedCall:
      case AndroidNotificationCategory.reminder:
      case AndroidNotificationCategory.workout:
        if (await Permission.scheduleExactAlarm.isGranted) {
          return AndroidScheduleMode.exact;
        }
        return AndroidScheduleMode.inexact;

      // General notifications: inexact scheduling is acceptable
      case AndroidNotificationCategory.email:
      case AndroidNotificationCategory.event:
      case AndroidNotificationCategory.locationSharing:
      case AndroidNotificationCategory.message:
      case AndroidNotificationCategory.navigation:
      case AndroidNotificationCategory.progress:
      case AndroidNotificationCategory.promo:
      case AndroidNotificationCategory.recommendation:
      case AndroidNotificationCategory.service:
      case AndroidNotificationCategory.social:
      case AndroidNotificationCategory.status:
      case AndroidNotificationCategory.stopwatch:
      case AndroidNotificationCategory.system:
      case AndroidNotificationCategory.transport:
        return AndroidScheduleMode.inexact;
    }
  }
}
