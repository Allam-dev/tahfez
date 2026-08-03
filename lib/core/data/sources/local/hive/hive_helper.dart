import 'package:hive_flutter/hive_flutter.dart';

abstract class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(HiveBoxes.httpCache.name);
  }
}

enum HiveBoxes { httpCache }