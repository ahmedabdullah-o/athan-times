import 'package:prayers_times/prayers_times.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/browser.dart' as tz;
import 'package:workmanager/workmanager.dart';

/*      DEBUG TOOLS.      */
bool get isDebug => kDebugMode;

void printDebug(String msg) {
  // ignore: avoid_print
  if (isDebug) print(msg);
}

/*        Services        */
class WorkManagerService {
  void callbackDispatcher({String? task}) {
    Workmanager().executeTask((String task, inputData) async {
      switch (task) {
        case 'prayer':
          String timezone = await TimezoneService().getLocalTimezone();
          PrayerTimes prayerTimes =
              PrayerTimesService().getPrayerTimes(DateTime.now(), timezone);
          String nextPrayer = (prayerTimes.nextPrayer() as String? ??
              prayerTimes.fajrStartTime!) as String;
          DateTime nextPrayerDateTime = prayerTimes.timeForPrayer(nextPrayer)!;

          await NotificationService.showNotification(
            scheduledDate: tz.TZDateTime(
              tz.getLocation(timezone),
              nextPrayerDateTime.year,
              nextPrayerDateTime.month,
              nextPrayerDateTime.day,
            ),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            channelId: 'prayer_notification',
            channelName: 'Prayer Notification',
            channelDescription:
                'Alarm-like prayer notification with your specified reciter\'s voice',
            channelIcon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
            notificationSound:
                RawResourceAndroidNotificationSound('notification_sound'),
            id: 0,
            title: nextPrayer,
            body: "It's time to pray $nextPrayer",
          );
          WorkManagerService().callbackDispatcher(task: 'prayer');
        default:
          return false;
      }
      return true;
    });
  }

  void initializeWorkmanager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode ? true : false,
    );

    await Workmanager().registerPeriodicTask(
      'midnightCheck',
      'midnightCheckTask',
      frequency: const Duration(minutes: 15),
    );
  }
}

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<bool> _requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires explicit permission
      if (await Permission.notification.isDenied) {
        return await Permission.notification.request().isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      // iOS always requires permission
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  static Future<void> initNotifications() async {
    _requestNotificationPermissions();
    if (_isInitialized) {
      printDebug(
          'Notification service is already initialized, reinitialization cancelled!');
      return;
    }
    printDebug('Initializing Notification service...');
    final androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
    _isInitialized = true;
  }

  static Future<void> showNotification({
    tz.TZDateTime? scheduledDate,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact,
    DateTimeComponents? repeatInterval,
    String channelId = 'general_channel',
    String channelName = 'General Channel',
    String? channelDescription,
    String? channelIcon,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
    AndroidNotificationSound? notificationSound,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    NotificationDetails notificationDetails() {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: channelIcon,
          importance: importance,
          priority: priority,
          sound: notificationSound,
        ),
        iOS: DarwinNotificationDetails(),
      );
    }

    return scheduledDate == null
        ? flutterLocalNotificationsPlugin.show(
            id,
            title,
            body,
            notificationDetails(),
            payload: payload,
          )
        : flutterLocalNotificationsPlugin.zonedSchedule(
            id, title, body, scheduledDate, notificationDetails(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: androidScheduleMode,
            matchDateTimeComponents: repeatInterval);
  }
}

class PrayerTimesService {
  List<Coordinates> coords = <Coordinates>[
    Coordinates(30.0444, 31.2357), // [0] cairo
  ];
  int selectedCoordsIndex = 0;
  List<String> madhab = <String>[
    PrayerMadhab.shafi, // [0] shafei
    PrayerMadhab.hanafi, // [1] hanafi
  ];
  int selectedMadhabIndex = 0;

  PrayerCalculationParameters params = PrayerCalculationMethod.egyptian();

  PrayerTimes getPrayerTimes(DateTime dateTime, String locationName) {
    printDebug('getPrayerTimes(): Fetching prayer times...');
    return PrayerTimes(
      coordinates: coords[selectedCoordsIndex],
      calculationParameters: params,
      locationName: locationName,
      precision: true,
      dateTime: dateTime,
    );
  }
}

class FileStorageService {
  Future<String> get _localPath async {
    printDebug('Fetching local path...');
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;
    printDebug('Fetching local file...');
    final File file = File("$path/coords.txt");
    if (!await file.exists()) await file.create(recursive: true);
    if (await file.length() < 2) {
      await file.writeAsString('00');
    }
    return file;
  }

  Future<String> readFile() async {
    try {
      final File file = await _localFile;
      printDebug('Reading local file...');
      String data = await file.readAsString();
      printDebug('Location read from: ${file.path}');
      return data;
    } catch (e) {
      printDebug('error reading file: $e');
      Fluttertoast.showToast(msg: "Couldn't retrieve saved coordinates.");
      return '0'; // select cairo by default
    }
  }

  Future<void> writeFile(String data) async {
    printDebug('Writing to local file...');
    final File file = await _localFile;
    await file.writeAsString(data);
  }
}

class TimezoneService {
  Future<String> getLocalTimezone() async {
    printDebug('Fetching local timezone...');
    return await FlutterTimezone.getLocalTimezone();
  }
}

class AthanStream {
  final PrayerTimesService prayerTimesService = PrayerTimesService();
  final TimezoneService _timezoneService = TimezoneService();

  Stream<String> get stream async* {
    final PrayerTimes prayerTimes = PrayerTimesService().getPrayerTimes(
      DateTime.now(),
      await _timezoneService.getLocalTimezone(),
    );
    while (true) {
      final DateTime now = DateTime.now();
      final DateTime? nextPrayerTime =
          prayerTimes.timeForPrayer(prayerTimes.nextPrayer(date: now));
      final Duration durationUntilNextPrayer;
      if (nextPrayerTime != null) {
        durationUntilNextPrayer = nextPrayerTime.difference(now);
      } else {
        PrayerTimes prayerTimesTomorrow = prayerTimesService.getPrayerTimes(
            now.add(Duration(days: 1)),
            await _timezoneService.getLocalTimezone());
        DateTime nextPrayer = prayerTimesTomorrow.fajrStartTime!;
        durationUntilNextPrayer = nextPrayer.difference(DateTime.now());
      }
      printDebug('Time until next prayer: $durationUntilNextPrayer');
      await Future.delayed(durationUntilNextPrayer);
      yield prayerTimes.currentPrayer();
    }
  }
}
