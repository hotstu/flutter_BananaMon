
import 'resourcProvider.dart';
import '../level_provider.dart' as base;

class LevelProvider extends base.LevelProvider {
  static LevelProvider instance;

  LevelProvider._init();

  factory LevelProvider.single() {
    if (instance == null) {
      instance = LevelProvider._init();
    }
    return instance;
  }

  @override
  getRawData(String name) async {
    final path = "/resource/level/${name}.png";
    return await readFile(path);
  }
}
