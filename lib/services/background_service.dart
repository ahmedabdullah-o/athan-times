import 'dart:async';
import 'dart:ui';
import 'package:athan_times/core/data.dart';
import 'package:athan_times/core/logic.dart';
import 'package:athan_times/services/notification_service.dart';
import 'package:athan_times/services/permission_service.dart';
import 'package:athan_times/services/prayer_times_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  service.on("start").listen((event) async {
    int waitingCount = 0;
    while (await Permission.ignoreBatteryOptimizations.isDenied) {
      if (waitingCount > 40) {
        Debug.printMsg(
          'Background Service have been for Permission: IgnoreBatteryOptimization. Permission has not been granted. Service might not work properly.',
        );
        ChannelInfo channelInfo = ChannelInfo(
          'error',
          'Error',
          'used for notifying the user of app errors',
        );
        NotificationInfo notificationInfo = NotificationInfo(
          50,
          'Battery Optimization Is Enabled',
          'Please Ignore Battery Optimization in App Settings',
          channelInfo,
        );

        SendNotifications().now(notificationInfo);
        break;
      }
      // Waiting for permission
      await Future.delayed(Duration(seconds: 1));
      Debug.printMsg(
        "waiting for permission granted: ignoreBatteryOptimization",
      );
      waitingCount++;
    }
  });

  service.on("stop").listen((event) {
    service.stopSelf();
    Debug.printMsg("background process is now stopped");
  });

  Timer.periodic(const Duration(hours: 24), (timer) {
    Debug.printMsg('Periodic background task started: ${DateTime.now()}');
    PrayerTimesService prayerTimesService = PrayerTimesService();
    prayerTimesService.scheduleNotificationsAll();
    Debug.printMsg(
      "Periodic background task has successfully finished: ${DateTime.now()}",
    );
  });
}

//TODO: Ios Background Service Implementation
@pragma('vm:entry-point')
Future<bool> iosBackgroundOnStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

class BackgroundService {
  void startBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("start");
    service.startService();
  }

  void stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    // Dependency Injection
    NotificationService notificationService = NotificationService();
    PermissionService permissionService = PermissionService();

    // Make sure required services are initialized.
    notificationService.initNotifications();

    // Request permissions.
    permissionService.androidIgnoreBatteryOptimization();

    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: iosBackgroundOnStart,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: false,
        notificationChannelId: 'background_service',
        foregroundServiceNotificationId: 0,
        foregroundServiceTypes: [AndroidForegroundType.specialUse],
      ),
    );
  }
}
