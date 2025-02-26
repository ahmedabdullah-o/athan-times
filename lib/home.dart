import 'package:athan_times/data_class.dart';
import 'package:flutter/material.dart';
import 'package:prayers_times/prayers_times.dart';
import 'services.dart';
import 'module.dart';

class Home extends StatefulWidget {
  final PrayerTimesService prayerTimesService;
  final String localTimeZone;
  final AthanStream athanStream;
  const Home({
    super.key,
    required this.prayerTimesService,
    required this.localTimeZone,
    required this.athanStream,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DateTime _now = DateTime.now();
  late PrayerTimes _prayerTimes;
  late AthanStream _athanStream;
  late String _currentPrayer;

  @override
  void initState() {
    super.initState();
    _prayerTimes = widget.prayerTimesService.getPrayerTimes(
      _now,
      widget.localTimeZone,
    );
    _athanStream = widget.athanStream;
    _currentPrayer = _prayerTimes.currentPrayer();
  }

  @override
  Widget build(BuildContext context) {
    final SunnahInsights sunnahInsights =
        SunnahInsights(_prayerTimes, precision: true);
    _athanStream.stream.listen(
      (prayer) {
        printDebug('Its $prayer time');
        NotificationService.showNotification(
          id: 0,
          title: prayer,
          body: 'It\'s time to pray $prayer',
        );
        setState(() {
          _currentPrayer = prayer;
        });
      },
    );

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
          printDebug('Its $_currentPrayer time');
          AppNotifications.athanNotification(
              title: _currentPrayer,
              body: 'It\'s time to pray $_currentPrayer');
        },
        icon: Icon(Icons.mosque),
      ),
    );
  }
}
