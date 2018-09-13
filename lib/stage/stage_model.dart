import 'package:image/image.dart';
import '../lib/canvas_wrapper.dart';
import 'mapItem_type.dart';

class StageModel {
  static const int w = 20;
  static const int h = 15;
  Array2d<int> wallPhase; //r
  Array2d<int> monsterPhase; //g
  Array2d<int> treasurePhase; //b
  int width;
  int height;
  CanvasWrapper canvas;

  StageModel(this.canvas, [this.width = w, this.height = h]) {
    wallPhase = Array2d(width, height, defaultValue: 0);
    monsterPhase = Array2d(width, height, defaultValue: 0);
    treasurePhase = Array2d(width, height, defaultValue: 0);
  }

  StageModel.fromImage(this.canvas, Image image) {
    //TODO 暂时用一张图保存，以后一张图要包含多个图层和其他资源
    //read from Image
    assert(image != null);
    this.width = image.width;
    this.height = image.height;
    wallPhase = Array2d(width, height, defaultValue: 0);
    monsterPhase = Array2d(width, height, defaultValue: 0);
    treasurePhase = Array2d(width, height, defaultValue: 0);
    for (var i = 0; i < width; ++i) {
      for (var j = 0; j < height; ++j) {
        var rgba = image.getPixel(i, j);
        int r = (rgba) & 0xFF;
        int g = (rgba >> 8) & 0xFF;
        int b = (rgba >> 16) & 0xFF;
        //int a = (rgba >> 24) & 0xFF;
        wallPhase[i][j] = r;
        monsterPhase[i][j] = g;
        treasurePhase[i][j] = b;
      }
    }
  }

  String exportBitmap() {
    Image image = new Image(this.width, this.height);
    for (var i = 0; i < width; ++i) {
      for (var j = 0; j < height; ++j) {
        int r = wallPhase[i][j];
        int g = monsterPhase[i][j];
        int b = treasurePhase[i][j];
        int a = (r == 0 && g == 0 && b == 0) ? 0 : 255;
        image.setPixelRGBA(i, j, r, g, b, a);
      }
    }
    return canvas.exportBitmap(image);
  }

  String getColor(int x, int y) {
    if (wallPhase[x][y] == 0 &&
        monsterPhase[x][y] == 0 &&
        treasurePhase[x][y] == 0) {
      return "rgba(0,0,0,0)";
    }
    return "rgba(${wallPhase[x][y]},${monsterPhase[x][y]},${treasurePhase[x][y]}, 255)";
  }

  int getCount(int x, int y) {
    return monsterPhase[x][y] & 0x0F;
  }

  void setState(int x, int y, MapItemType input) {
    switch (input) {
      case MapItemType.Erase:
        wallPhase[x][y] = 0;
        monsterPhase[x][y] = 0;
        treasurePhase[x][y] = 0;
        break;
      case MapItemType.Wall0:
      case MapItemType.Wall1:
      case MapItemType.Wall2:
      case MapItemType.Wall3:
      case MapItemType.Wall4:
      case MapItemType.Wall5:
      case MapItemType.Wall6:
      case MapItemType.Wall7:
      case MapItemType.Wall8:
      case MapItemType.Wall9:
      case MapItemType.WallA:
      case MapItemType.WallB:
      case MapItemType.WallC:
      case MapItemType.WallD:
      case MapItemType.WallE:
        wallPhase[x][y] = 0x7f;
        break;
      case MapItemType.WallF:
        wallPhase[x][y] = 0xff;
        //wallF和其他元素相斥
        monsterPhase[x][y] = 0;
        treasurePhase[x][y] = 0;
        break;
      case MapItemType.Monster0:
      case MapItemType.Monster1:
      case MapItemType.Monster2:
      case MapItemType.Monster3:
      case MapItemType.Monster4:
      case MapItemType.Monster5:
      case MapItemType.Monster6:
      case MapItemType.Monster7:
      case MapItemType.Monster8:
      case MapItemType.Monster9:
      case MapItemType.MonsterA:
      case MapItemType.MonsterB:
      case MapItemType.MonsterC:
      case MapItemType.MonsterD:
      case MapItemType.MonsterE:
      case MapItemType.MonsterF:
        if (wallPhase[x][y] == 0xff) {
          break;
        }
        var current = monsterPhase[x][y];
        int count = (current + 1) & 0x0F;
        monsterPhase[x][y] = (input.index - 0x10) * 0x10 + count;
        break;
      case MapItemType.Supply0:
      case MapItemType.Supply1:
      case MapItemType.Supply2:
      case MapItemType.Supply3:
      case MapItemType.Supply4:
      case MapItemType.Supply5:
      case MapItemType.Supply6:
      case MapItemType.Supply7:
      case MapItemType.Supply8:
      case MapItemType.Supply9:
      case MapItemType.SupplyA:
      case MapItemType.SupplyB:
      case MapItemType.SupplyC:
      case MapItemType.SupplyD:
      case MapItemType.SupplyE:
      case MapItemType.SupplyF:
        if (wallPhase[x][y] == 0xff) {
          break;
        }
        treasurePhase[x][y] = (input.index - 0x20) * 0x10 + 0xf;
        break;
    }
  }
}

/*
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
class Array2d<T> {
  List<List<T>> array;
  T defaultValue = null;

  Function defaultFactory;
  final width;
  final height;

  Array2d(int this.width, int this.height,
      {T this.defaultValue, Function this.defaultFactory}) {
    array = new List<List<T>>();
    for (var x = 0; x < width; ++x) {
      List<T> temp = [];
      array.add(temp);
      for (var y = 0; y < height; ++y) {
        temp.add(getdefaultValue(x, y));
      }

    }
  }

  T getdefaultValue(int x, int y) {
    if(defaultFactory != null && defaultValue == null) {
      return defaultFactory(this, x, y);
    } else {
      return defaultValue;
    }
  }

  operator [](int x) => array[x];


}
