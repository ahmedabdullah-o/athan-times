//ExternalPackages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//LocalImports
import 'package:athan_times/core/data.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard(
      {super.key, required this.prayerName, required this.prayerDateTime});

  final String prayerName;
  final DateTime prayerDateTime;

  @override
  Widget build(BuildContext context) {
    String prayerTimeString = DateFormat("HH:mm").format(prayerDateTime);
    return Container(
      width: double.infinity,
      height: 50,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
          color: CoreColors.black55,
          border: Border.all(color: CoreColors.black55, width: 8),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                prayerName,
                style: CoreFonts.dongleWhiteSmoke,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                prayerTimeString,
                style: CoreFonts.dongleWhiteSmoke,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  color: CoreColors.whiteSmoke,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
