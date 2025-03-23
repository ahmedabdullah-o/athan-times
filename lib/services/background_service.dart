import 'dart:async';
import 'package:athan_times/services/global_functions.dart';
import 'package:athan_times/services/notification_service.dart';
import 'package:athan_times/services/permission_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

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
        onForeground: backgroundOnStart,
        onBackground: iosBackgroundOnStart,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundOnStart,
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
