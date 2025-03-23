import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Debug {
  static bool get isDebug => kDebugMode;

  static void printMsg(String msg) {
    // ignore: avoid_print
    if (isDebug) print(msg);
  }
}

class Layout {
  bool isDark(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }
}

class HandleExcep {
  void isValidId(int? id) {
    if (id == null) throw Exception("notification id can't have value of null");
  }
}

class Check {
  static bool isPersistentNotificationCategory(
    AndroidNotificationCategory? category,
  ) {
    switch (category) {
      case AndroidNotificationCategory.alarm:
      case AndroidNotificationCategory.call:
      case AndroidNotificationCategory.navigation:
      case AndroidNotificationCategory.progress:
      case AndroidNotificationCategory.service:
      case AndroidNotificationCategory.status:
      case AndroidNotificationCategory.stopwatch:
      case AndroidNotificationCategory.workout:
        return true;
      default:
        return false;
    }
  }
}
