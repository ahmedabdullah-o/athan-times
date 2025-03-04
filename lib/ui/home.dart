//ExternalPackages
import 'package:flutter/material.dart';
import 'package:prayers_times/prayers_times.dart';
//LocalImports
import 'package:athan_times/ui/services/core/data.dart';
import 'package:athan_times/ui/services/core/logic.dart';
import 'package:athan_times/ui/services/services.dart';
import 'package:athan_times/ui/modules.dart';

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
  late String _currentPrayer;

  @override
  void initState() {
    super.initState();
    _prayerTimes = widget.prayerTimesService.getPrayerTimes(
      _now,
      widget.localTimeZone,
    );
    _currentPrayer = _prayerTimes.currentPrayer();
  }

  @override
  Widget build(BuildContext context) {
    final SunnahInsights sunnahInsights =
        SunnahInsights(_prayerTimes, precision: true);

    return Scaffold(
      body: ListView(
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
      floatingActionButton: IconButton(
        onPressed: () {
          Debug.printMsg('Its $_currentPrayer time');
          CoreNotificationInfo notificationInfo =
              CoreNotificationInfo(id: 0, title: 'FAB notification');
          SendNotifications.persistent(
            notificationInfo,
          );
        },
        icon: Icon(Icons.mosque),
      ),
    );
  }
}
