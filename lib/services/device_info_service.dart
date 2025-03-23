import 'dart:io';
import 'package:athan_times/core/logic.dart';

class DeviceInfoService {
  int? get sdkVersion {
    if (Platform.isAndroid) {
      int sdkVersion = int.parse(Platform.version.split(' ')[0]);
      Debug.printMsg('Android SDK version: $sdkVersion');
      return sdkVersion;
    } else {
      return null;
    }
  }
}
