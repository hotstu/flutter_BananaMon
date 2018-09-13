import 'package:vector_math/vector_math.dart';

import '../char/base_char.dart';
import '../char/brick.dart';
import '../stage/stage_model.dart';
import 'canvas_wrapper.dart';
import 'rect.dart';

class ChessPad extends Array2d<Block> {
  final num width;
  final num height;
  final CanvasWrapper ctx;

  ChessPad(this.ctx, num this.width, num this.height)
      : super(width, height,
            defaultFactory: (conatiner, x, y) => new Block(conatiner, x, y));
  bool inRange(num x, num y) => (x >= 0 && x < width && y >= 0 && y < height);

}

class Block {
  final List<Brick> bricks = [];
  final List<BaseChar> others = [];
  final int x;
  final int y;
  final ChessPad chessPad;
  Rect<num> rect;
  List<Block> _adjBlocks;
  Vector2 _center;

  Block(this.chessPad, this.x, this.y){
    var py = chessPad.ctx.lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    rect = Rect(py.x, py.y, 40, 40);
  }

  void add(BaseChar char) {
    if (char is Brick) {
      _addBrick(char);
    } else {
      _addOther(char);
    }
  }

  void remove(BaseChar char) {
    if (char is Brick) {
      _removeBrick(char);
    } else {
      _removeOther(char);
    }
  }

  bool hasBrick() => (bricks.length > 0);

  List<Block> get adjBlocks {
    if (_adjBlocks == null) {
      Block l = (!chessPad.inRange(x - 1, y)) ? null : chessPad[x - 1][y];
      Block lt = (!chessPad.inRange(x - 1, y -1)) ? null : chessPad[x - 1][y-1];
      Block t = (!chessPad.inRange(x , y - 1)) ? null : chessPad[x][y - 1];
      Block rt = (!chessPad.inRange(x+1 , y - 1)) ? null : chessPad[x+1][y - 1];
      Block r = (!chessPad.inRange(x + 1, y )) ? null : chessPad[x + 1][y];
      Block rd = (!chessPad.inRange(x + 1, y+1 )) ? null : chessPad[x + 1][y+1];
      Block d = (!chessPad.inRange(x , y + 1))? null : chessPad[x][y + 1];
      Block ld = (!chessPad.inRange(x-1 , y + 1))? null : chessPad[x-1][y + 1];
      _adjBlocks = [l, t, r, d, lt, rt, rd,ld];
    }
    return _adjBlocks;
  }

  void _addBrick(Brick brick) {
    if (bricks.indexOf(brick) == -1) {
      bricks.add(brick);
    }
  }

  Vector2 get center {
    if(_center == null) {
      _center = chessPad.ctx.lo2pyProjection(Vector2(x.toDouble(),y.toDouble()));
    }
    return _center;
  }

  void _addOther(BaseChar char) {
    if (others.indexOf(char) == -1) {
      others.add(char);
    }
  }

  void _removeBrick(Brick char) {
    bricks.remove(char);
  }

  void _removeOther(BaseChar char) {
    others.remove(char);
  }
}
