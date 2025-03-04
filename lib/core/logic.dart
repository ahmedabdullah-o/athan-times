import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Debug {
  static bool get isDebug => kDebugMode;

  static void printMsg(String msg) {
    // ignore: avoid_print
    if (isDebug) print(msg);
  }
}

class Layout {
  bool isDark(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }
}

class HandleExcep {
  void isValidId(int? id) {
    if (id == null) throw Exception("notification id can't have value of null");
  }
}
