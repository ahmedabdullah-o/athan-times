//ExternalPackages
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:athan_times/core/logic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> androidIgnoreBatteryOptimization() async {
    if (Platform.isAndroid) {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await AppSettings.openAppSettings(
          type: AppSettingsType.batteryOptimization,
        );
        //TODO: toast message needs to be clearer
        Fluttertoast.showToast(
          msg: 'Permission Needed For Notification Management',
        );
      }
    }
  }

  Future<void> androidAllowExactAlarm() async {
    // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
    // Using this permission may make app distribution difficult due to Google policy.
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await AppSettings.openAppSettings(type: AppSettingsType.alarm);
      }
      //TODO: toast message needs to be clearer
      Fluttertoast.showToast(msg: 'Permission Needed For Notifications');
    }
  }

  Future<bool> allowNotifications() async {
    Debug.printMsg('Requesting notification permission');
    if (Platform.isAndroid) {
      // Android 13+ requires explicit permission
      if (await Permission.notification.isDenied) {
        return await Permission.notification.request().isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      // iOS always requires permission
      return await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }
}
