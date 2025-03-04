//ExternalPackages
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:workmanager/workmanager.dart';
import 'dart:async';

//LocalImports
import 'package:athan_times/core/logic.dart';
import 'package:athan_times/services/services.dart';
import 'package:athan_times/ui/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  // Service instantiation
  final FileStorageService fileStorageService = FileStorageService();
  final TimezoneService timezoneService = TimezoneService();
  final PrayerTimesService prayerTimesService = PrayerTimesService();

  // Load saved data
  String fileData = await fileStorageService.readFile();
  prayerTimesService.selectedCoordsIndex = int.parse(fileData[0]);
  prayerTimesService.selectedMadhabIndex = int.parse(fileData[1]);
  // Fetch local timezone
  String localTimeZone = await timezoneService.getLocalTimezone();
  Debug.printMsg('Local timezone: $localTimeZone');

  // Service init
  await NotificationService.initNotifications();
  await WorkManagerService().initializeWorkmanager();
  Workmanager().registerOneOffTask('prayer', 'prayer',
      existingWorkPolicy: ExistingWorkPolicy.replace);

  runApp(MyApp(
    prayerTimesService: prayerTimesService,
    localTimeZone: localTimeZone,
  ));
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
        prayerTimesService.madhab[prayerTimesService.selectedMadhabIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Prayer Times",
      color: Colors.lightGreen,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
        ),
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
