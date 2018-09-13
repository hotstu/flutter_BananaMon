import 'dart:math';

import 'package:vector_math/vector_math.dart';

class Rect<T extends num> extends MutableRectangle<T> {
  Rect(num left, num top, num width, num height) : super(left, top, width, height);

  Vector2 get topLeftV {
    return Vector2(left+0.0, top+0.0);
  }
  Vector2 get centerV {
    return Vector2(left + .5*width, top + .5* height);
  }
  Point<num> get center {
    return Point(left + .5*width, top + .5* height);
  }

  Rect clone() => new Rect(left, top, width, height);

  void offset(Vector2 diff) {
    left += diff.x;
    top += diff.y;
  }

  operator +(Vector2 offset) {
    Rect copy = clone();
    copy.left += offset.x;
    copy.top += offset.y;
    return copy;
  }

  operator -(Vector2 offset) {
    Rect copy = clone();
    copy.left -= offset.x;
    copy.top -= offset.y;
    return copy;
  }
}