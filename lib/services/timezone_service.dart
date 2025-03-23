//ExternalPackages
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/standalone.dart' as tz;
//LocalImports
import 'package:athan_times/core/logic.dart';

class TimezoneService {
  Future<String> getLocalTZAsString() async {
    Debug.printMsg('Fetching local timezone as String...');
    return await FlutterTimezone.getLocalTimezone();
  }

  Future<tz.Location> getLocalTZAsLocation() async {
    Debug.printMsg('Fetching local timezone as Location...');
    return tz.getLocation(await getLocalTZAsString());
  }
}
