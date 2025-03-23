import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:async';
//LocalImports
import 'package:athan_times/core/logic.dart';
import 'package:athan_times/ui/home.dart';
import 'package:athan_times/services/permission_service.dart';
import 'package:athan_times/services/file_storage_service.dart';
import 'package:athan_times/services/notification_service.dart';
import 'package:athan_times/services/prayer_times_service.dart';
import 'package:athan_times/services/timezone_service.dart';
import 'package:athan_times/services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  // Service instantiation
  final notificationService = NotificationService();
  final fileStorageService = FileStorageService();
  final timezoneService = TimezoneService();
  final prayerTimesService = PrayerTimesService();
  final backgroundService = BackgroundService();
  final permissionService = PermissionService();

  // Load saved data
  String fileData = await fileStorageService.readFile();
  PrayerTimesService.selectedCoordsIndex = int.parse(fileData[0]);
  PrayerTimesService.selectedMadhabIndex = int.parse(fileData[1]);

  // Fetch local timezone
  String localTimeZone = await timezoneService.getLocalTZAsString();
  Debug.printMsg('Local timezone: $localTimeZone');

  // Fetch Device Info

  //Permissions
  await permissionService.androidAllowExactAlarm();

  // Service init
  await notificationService.initNotifications();
  await backgroundService.initializeService();

  // Service start
  backgroundService.startBackgroundService();

  runApp(
    MyApp(prayerTimesService: prayerTimesService, localTimeZone: localTimeZone),
  );
}

class MyApp extends StatelessWidget {
  final PrayerTimesService prayerTimesService;
  final String localTimeZone;
  const MyApp({
    super.key,
    required this.prayerTimesService,
    required this.localTimeZone,
  });

  @override
  Widget build(BuildContext context) {
    prayerTimesService.params.madhab =
        prayerTimesService.madhab[PrayerTimesService.selectedMadhabIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Prayer Times",
      color: Colors.lightGreen,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.lightGreen,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Home(
        prayerTimesService: prayerTimesService,
        localTimeZone: localTimeZone,
      ),
    );
  }
}
