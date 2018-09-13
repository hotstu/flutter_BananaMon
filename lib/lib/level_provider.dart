import 'dart:async';

import 'package:image/image.dart';

import '../stage/stage_model.dart';
import '../lib/constants.dart' as constants;

abstract class LevelProvider {
  static const levels = const ["s1", "s2", "s3"];

  getRawData(String name);

  Future<StageModel> obtain(String level) async {
    var decodePng2 = decodePng(await getRawData(level));
    assert(decodePng2.height == constants.logicalHeight &&
        decodePng2.width == constants.logicalWidth);
    return StageModel.fromImage(null, decodePng2);
  }
}
