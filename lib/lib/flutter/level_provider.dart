
import 'dart:typed_data';

import '../level_provider.dart' as base;
import 'package:flutter/services.dart' show rootBundle;

class LevelProvider extends base.LevelProvider {
  static LevelProvider instance;

  LevelProvider._init();

  factory LevelProvider.single() {
    if (instance == null) {
      instance = LevelProvider._init();
    }
    return instance;
  }

  readFile(path) async {
    ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  getRawData(String name) async {
    final path = "assets/resource/level/${name}.png";
    return await readFile(path);
  }
}
