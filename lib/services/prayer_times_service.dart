//ExternalPackages
import 'package:athan_times/core/data.dart';
import 'package:athan_times/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:prayers_times/prayers_times.dart';
//LocalImports
import 'package:athan_times/core/logic.dart';
import 'package:athan_times/services/timezone_service.dart';

class PrayerTimesService {
  List<Coordinates> coords = <Coordinates>[
    Coordinates(30.0444, 31.2357), // [0] cairo
  ];
  static int selectedCoordsIndex = 0;

  List<String> madhab = <String>[
    PrayerMadhab.shafi, // [0] shafei
    PrayerMadhab.hanafi, // [1] hanafi
  ];
  static int selectedMadhabIndex = 0;

  //TODO: make params and notificationSound customizable
  PrayerCalculationParameters params = PrayerCalculationMethod.egyptian();
  AndroidNotificationSound notificationSound =
      RawResourceAndroidNotificationSound('notification_sound');

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

  Future<void> scheduleNotificationsAll() async {
    Debug.printMsg(
      'PrayerTimesService.scheduleNotificationsAll(): Initializing...',
    );

    tzdata.initializeTimeZones();
    TimezoneService timezoneService = TimezoneService();
    String timezoneAsString = await timezoneService.getLocalTZAsString();
    tz.Location timezoneAsLocation =
        await timezoneService.getLocalTZAsLocation();
    SendNotifications sendNotifications = SendNotifications();
    DateTime now = DateTime.now();

    PrayerTimes prayerTimes = getPrayerTimes(now, timezoneAsString),
        prayerTimesTomorrow = getPrayerTimes(
          now.add(Duration(days: 1)),
          timezoneAsString,
        );

    List<tz.TZDateTime> zonedPrayerTimes = [
      tz.TZDateTime.from(prayerTimes.fajrStartTime!, timezoneAsLocation),
      tz.TZDateTime.from(prayerTimes.dhuhrStartTime!, timezoneAsLocation),
      tz.TZDateTime.from(prayerTimes.asrStartTime!, timezoneAsLocation),
      tz.TZDateTime.from(prayerTimes.maghribStartTime!, timezoneAsLocation),
      tz.TZDateTime.from(prayerTimes.ishaStartTime!, timezoneAsLocation),
    ];

    List<tz.TZDateTime> zonedPrayerTimesTomorrow = [
      tz.TZDateTime.from(
        prayerTimesTomorrow.fajrStartTime!,
        timezoneAsLocation,
      ),
      tz.TZDateTime.from(
        prayerTimesTomorrow.dhuhrStartTime!,
        timezoneAsLocation,
      ),
      tz.TZDateTime.from(prayerTimesTomorrow.asrStartTime!, timezoneAsLocation),
      tz.TZDateTime.from(
        prayerTimesTomorrow.maghribStartTime!,
        timezoneAsLocation,
      ),
      tz.TZDateTime.from(
        prayerTimesTomorrow.ishaStartTime!,
        timezoneAsLocation,
      ),
    ];

    ChannelInfo channelInfo = ChannelInfo(
      'prayer_notification',
      'Prayer Notification',
      "notification sent at the time of the prayer with your specified reciter's voice",
    );

    List<String> prayerName = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    //NOTE: Notification id, the first digit is for prayer times notification, and the second digit is the prayer number
    List<NotificationInfo> notificationInfo = [];

    for (int i = 0; i < 5; i++) {
      NotificationInfo info = NotificationInfo(
        11 + i,
        prayerName[i],
        "it's time to pray ${prayerName[i]}",
        channelInfo,
        category: AndroidNotificationCategory.alarm,
        notificationSound: notificationSound,
        importance: Importance.max,
      );
      if (notificationInfo.length < i + 1) {
        notificationInfo.add(info);
      } else {
        notificationInfo[i] = info;
      }
    }
    Debug.printMsg(
      'PrayerTimesService.scheduleNotificationsAll(): Scheduling Notifications...',
    );

    for (int i = 0; i < 5; i++) {
      if (now.isBefore(zonedPrayerTimes[0])) {
        sendNotifications.scheduled(
          notificationInfo[i],
          channelInfo,
          zonedPrayerTimes[0],
        );
      } else {
        sendNotifications.scheduled(
          notificationInfo[i],
          channelInfo,
          zonedPrayerTimesTomorrow[0],
        );
      }
    }
    Debug.printMsg('PrayerTimesService.scheduleNotificationsAll(): Done!');
  }
}
