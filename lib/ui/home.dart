//ExternalPackages
import 'package:athan_times/core/data.dart';
import 'package:athan_times/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayers_times/prayers_times.dart';
//LocalImports
import 'package:athan_times/ui/modules.dart';
import 'package:athan_times/services/prayer_times_service.dart';

class Home extends StatefulWidget {
  final PrayerTimesService prayerTimesService;
  final String localTimeZone;
  const Home({
    super.key,
    required this.prayerTimesService,
    required this.localTimeZone,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DateTime _now = DateTime.now();
  late PrayerTimes _prayerTimes;

  @override
  void initState() {
    super.initState();
    _prayerTimes = widget.prayerTimesService.getPrayerTimes(
      _now,
      widget.localTimeZone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SunnahInsights sunnahInsights = SunnahInsights(
      _prayerTimes,
      precision: true,
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ListView(
              children: <PrayerCard>[
                PrayerCard(
                  prayerName: "Fajr",
                  prayerDateTime: _prayerTimes.fajrStartTime!,
                ),
                PrayerCard(
                  prayerName: "Sunrise",
                  prayerDateTime: _prayerTimes.sunrise!,
                ),
                PrayerCard(
                  prayerName: "Dhuhr",
                  prayerDateTime: _prayerTimes.dhuhrStartTime!,
                ),
                PrayerCard(
                  prayerName: "Asr",
                  prayerDateTime: _prayerTimes.asrStartTime!,
                ),
                PrayerCard(
                  prayerName: "Maghrib",
                  prayerDateTime: _prayerTimes.maghribStartTime!,
                ),
                PrayerCard(
                  prayerName: "Isha",
                  prayerDateTime: _prayerTimes.ishaStartTime!,
                ),
                PrayerCard(
                  prayerName: "Midnight",
                  prayerDateTime: sunnahInsights.middleOfTheNight,
                ),
                PrayerCard(
                  prayerName: "Last Third",
                  prayerDateTime: sunnahInsights.lastThirdOfTheNight,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        tooltip: 'for testing\n(foreground service)',
        onPressed: () async {
          SendNotifications().now(
            NotificationInfo.formCategory(
              1234,
              'title',
              'body',
              AndroidNotificationCategory.service,
              payload: 'navigateAndroidAppSettings',
            ),
          );
        },
        icon: Icon(Icons.mosque),
      ),
    );
  }
}
