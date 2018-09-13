import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math' as math;
import '../../lib/chess_pad.dart';
import '../../lib/rect.dart';
import '../base_char.dart';

abstract class Leg {
  BaseChar get delegate;

  bool canIGo(num lox, num loy);

  void move() {
    if (delegate.speed == 0 || (delegate.v.x == 0 && delegate.v.y == 0)) {
      return;
    }
    var current = delegate.current;
    //print("${delegate.name} ${lo}");
    if (current != null) {
      Vector2 offset = delegate.v * delegate.speed;
      Rect dest = delegate.rect + offset;
      List<Block> adjs = current.adjBlocks;

      var next;
      if (delegate.v.x < 0) {
        next = [adjs[0], adjs[4], adjs[7]].asMap().map((index, b) {
          if (b != null) {
            return MapEntry(index, Tuple2(b, b.rect));
          } else {
            num dd = 0;
            if (index == 1) {
              dd = -40;
            }
            if (index == 2) {
              dd = 40;
            }
            return MapEntry(
                index, Tuple2(b, current.rect + Vector2(-40.0, dd)));
          }
        }).values;
      } else if (delegate.v.y < 0) {
        next = [adjs[1], adjs[4], adjs[5]].asMap().map((index, b) {
          if (b != null) {
            return MapEntry(index, Tuple2(b, b.rect));
          } else {
            num dd = 0;
            if (index == 1) {
              dd = -40;
            }
            if (index == 2) {
              dd = 40;
            }
            return MapEntry(
                index,
                Tuple2(
                    b,
                    current.rect +
                        Vector2(
                          dd,
                          -40.0,
                        )));
          }
        }).values;
      } else if (delegate.v.x > 0) {
        next = [adjs[2], adjs[5], adjs[6]].asMap().map((index, b) {
          if (b != null) {
            return MapEntry(index, Tuple2(b, b.rect));
          } else {
            num dd = 0;
            if (index == 1) {
              dd = -40;
            }
            if (index == 2) {
              dd = 40;
            }
            return MapEntry(index, Tuple2(b, current.rect + Vector2(40.0, dd)));
          }
        }).values;
      } else if (delegate.v.y > 0) {
        next = [adjs[3], adjs[6], adjs[7]].asMap().map((index, b) {
          if (b != null) {
            return MapEntry(index, Tuple2(b, b.rect));
          } else {
            num dd = 0;
            if (index == 1) {
              dd = 40;
            }
            if (index == 2) {
              dd = -40;
            }
            return MapEntry(index, Tuple2(b, current.rect + Vector2(dd, 40.0)));
          }
        }).values;
      } else {
        next = [];
      }
      num maxInterWidth = 0;
      num maxInterHeight = 0;
      var r = next
          .where((t) =>
              (t.item1 == null || !canIGo(t.item1.x, t.item1.y)) &&
              dest.intersects(t.item2))
          .map((t) => dest.intersection(t.item2))
          .where((i) {
        return (i.width > 1 && i.height > 1 );
      });

      r.forEach((i) {
        if (i != null) {
          maxInterHeight = math.max(maxInterHeight, i.height);
          maxInterWidth = math.max(maxInterWidth, i.width);
        }
      });

      if (r.length > 0) {
        if (delegate.v.x == 0 && maxInterWidth != 0 && maxInterWidth <= 15) {
          //垂直前进方向有障碍,向中间微移, 让转角更顺滑
          var vector2 = current.rect.centerV - delegate.rect.centerV;
          if(vector2.x.abs() <= delegate.speed) {
            offset.x += vector2.x.toInt();
          } else {
            vector2.normalize();
            var d = vector2 * delegate.speed;
            offset.x += d.x.toInt();
          }

          print("微移d = ${offset.x}");
          offset.y -= maxInterHeight * delegate.v.y;
        } else if (delegate.v.y == 0 &&
            maxInterHeight != 0 &&
            maxInterHeight <= 15) {
          //垂直前进方向有障碍
          var vector2 = current.rect.centerV - delegate.rect.centerV;
          if(vector2.y.abs() <= delegate.speed) {
            offset.y += vector2.y.toInt();
          } else {
            vector2.normalize();
            var d = vector2 * delegate.speed;
            offset.y += d.y.toInt();
          }
          offset.x -= maxInterWidth * delegate.v.x;
        } else {
          offset.x -= maxInterWidth * delegate.v.x;
          offset.y -= maxInterHeight * delegate.v.y;
          delegate.v = Vector2.zero();
        }
      }
      delegate.offset(offset);
    }
  }
}
