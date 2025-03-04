//ExternalPackages
import 'package:prayers_times/prayers_times.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart';
import 'package:workmanager/workmanager.dart';
//LocalImports
import 'package:athan_times/ui/services/core/data.dart';
import 'package:athan_times/ui/services/core/logic.dart';

class WorkManagerService {
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask(
      (task, inputData) async {
        Debug.printMsg("callbackDispatcher(): creating task '$task'");
        switch (task) {
          case 'prayer':
            Debug.printMsg("task 'prayer' starting...");
            tz.Location timezoneLocation =
                await TimezoneService().getLocalLocation();
            String timezoneString = await TimezoneService().getLocalTimezone();
            PrayerTimes prayerTimes = PrayerTimesService()
                .getPrayerTimes(DateTime.now(), timezoneString);
            String nextPrayer = prayerTimes.nextPrayer();
            TZDateTime nextPrayerDateTime = TZDateTime.from(
                prayerTimes.timeForPrayer(nextPrayer)!, timezoneLocation);

            CoreNotificationInfo notificationInfoScheduled =
                CoreNotificationInfo(
              id: 2,
              title: nextPrayer,
            );

            //TODO: send a persistent notification using flutter_foreground_task
            await SendNotifications.scheduled(nextPrayerDateTime,
                CoreNotificationType.alarm, notificationInfoScheduled);
            Workmanager().registerOneOffTask('prayer', 'prayer',
                existingWorkPolicy: ExistingWorkPolicy.append);
            Debug.printMsg("Task 'prayer' finished successfully.");
          default:
            return false;
        }
        return true;
      },
    );
  }

  Future<void> initializeWorkmanager() async {
    Debug.printMsg('Initializing Workmanager...');
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: Debug.isDebug ? true : false,
    );
  }
}

///flutter_local_notification.dart implementation
class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<bool> _requestNotificationPermissions() async {
    Debug.printMsg('Requesting notification permission');
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

  ///Crucial to run before using the class
  static Future<void> initNotifications() async {
    _requestNotificationPermissions();
    if (_isInitialized) {
      Debug.printMsg(
          'Notification service is already initialized, reinitialization cancelled!');
      return;
    }
    Debug.printMsg('Initializing Notification service...');
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

  ///Show notifications and alter every bit of data in it. NOTE: the property
  ///'isPersistent' is an abstracted version of the required settings to make
  ///a notification persistent
  static Future<void> show(
    int id, {
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
    String? title,
    String? body,
    String? payload,
    bool isPersistent = false,
  }) async {
    NotificationDetails notificationDetailsNormal() {
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

    NotificationDetails notificationDetailsPersistent() {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: channelIcon,
          importance: importance,
          priority: priority,
          sound: notificationSound,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          silent: true,
        ),
        iOS: DarwinNotificationDetails(),
      );
    }

    return scheduledDate == null
        ? flutterLocalNotificationsPlugin.show(
            id,
            title,
            body,
            isPersistent
                ? notificationDetailsPersistent()
                : notificationDetailsNormal(),
            payload: payload,
          )
        : flutterLocalNotificationsPlugin.zonedSchedule(
            id, title, body, scheduledDate, notificationDetailsNormal(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: androidScheduleMode,
            matchDateTimeComponents: repeatInterval);
  }
}

///This is an abstracted version of the
///NotificationService() class and it's method
///NotificationService().show()
abstract final class SendNotifications {
  ///Main SendNotification method
  ///Sends notifications based on info
  static Future<void> ofInfo(
    CoreChannelInfo channelInfo,
    CoreNotificationInfo notificationInfo, {
    TZDateTime? scheduledAt,
    DateTimeComponents? repeatInterval,
    bool isPersistent = false,
  }) async {
    return NotificationService.show(
      notificationInfo.id,
      scheduledDate: scheduledAt,
      androidScheduleMode: (channelInfo.channelId == 'prayer_notification'
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.exact),
      repeatInterval: repeatInterval,
      channelId: channelInfo.channelId,
      channelName: channelInfo.channelName,
      channelDescription: channelInfo.channelDesc,
      channelIcon: channelInfo.channelIcon,
      importance: channelInfo.importance,
      priority: channelInfo.priority,
      notificationSound: notificationInfo.notificationSound,
      title: notificationInfo.title,
      body: notificationInfo.body,
      payload: notificationInfo.payload,
      isPersistent: isPersistent,
    );
  }

  static Future<void> alarm(
    CoreNotificationInfo notificationInfo,
  ) async {
    CoreNotificationType notificationType = CoreNotificationType.alarm;
    CoreChannelInfo channelInfo = CoreChannelInfo.getFromType(notificationType);
    ofInfo(channelInfo, notificationInfo);
  }

  static Future<void> persistent(
    CoreNotificationInfo notificationInfo,
  ) async {
    CoreNotificationType notificationType = CoreNotificationType.persistent;
    CoreChannelInfo channelInfo = CoreChannelInfo.getFromType(notificationType);
    ofInfo(channelInfo, notificationInfo, isPersistent: true);
  }

  static Future<void> general(
    CoreNotificationInfo notificationInfo,
  ) async {
    CoreNotificationType notificationType = CoreNotificationType.general;
    CoreChannelInfo channelInfo = CoreChannelInfo.getFromType(notificationType);
    ofInfo(channelInfo, notificationInfo);
  }

  static Future<void> scheduled(
    TZDateTime dateTime,
    CoreNotificationType notificationType,
    CoreNotificationInfo notificationInfo,
  ) async {
    CoreChannelInfo channelInfo = CoreChannelInfo.getFromType(notificationType);
    ofInfo(channelInfo, notificationInfo);
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
    Debug.printMsg('getPrayerTimes(): Fetching prayer times...');
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
    Debug.printMsg('Fetching local path...');
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;
    Debug.printMsg('Fetching local file...');
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
      Debug.printMsg('Reading local file...');
      String data = await file.readAsString();
      Debug.printMsg('Location read from: ${file.path}');
      return data;
    } catch (e) {
      Debug.printMsg('error reading file: $e');
      Fluttertoast.showToast(msg: "Couldn't retrieve saved coordinates.");
      return '0'; // select cairo by default
    }
  }

  Future<void> writeFile(String data) async {
    Debug.printMsg('Writing to local file...');
    final File file = await _localFile;
    await file.writeAsString(data);
  }
}

class TimezoneService {
  Future<String> getLocalTimezone() async {
    Debug.printMsg('Fetching local timezone as String...');
    return await FlutterTimezone.getLocalTimezone();
  }

  Future<tz.Location> getLocalLocation() async {
    Debug.printMsg('Fetching local timezone as Location...');
    return tz.getLocation(await getLocalTimezone());
  }
}
