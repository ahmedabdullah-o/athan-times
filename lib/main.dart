import 'package:flutter/material.dart';
import 'dart:async';
import 'services.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Service instantiation
  final FileStorageService fileStorageService = FileStorageService();
  final TimezoneService timezoneService = TimezoneService();
  final PrayerTimesService prayerTimesService = PrayerTimesService();
  final AthanStream athanStream = AthanStream();

  // Load saved data
  String fileData = await fileStorageService.readFile();
  prayerTimesService.selectedCoordsIndex = int.parse(fileData[0]);
  prayerTimesService.selectedMadhabIndex = int.parse(fileData[1]);
  // Fetch local timezone
  String localTimeZone = await timezoneService.getLocalTimezone();
  printDebug('Local timezone: $localTimeZone');

  // Service init
  NotificationService.initNotifications();

  runApp(MyApp(
    prayerTimesService: prayerTimesService,
    localTimeZone: localTimeZone,
    athanStream: athanStream,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerTimesService prayerTimesService;
  final String localTimeZone;
  final AthanStream athanStream;
  const MyApp({
    super.key,
    required this.prayerTimesService,
    required this.localTimeZone,
    required this.athanStream,
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
        athanStream: athanStream,
      ),
    );
  }
}
