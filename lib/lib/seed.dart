import 'dart:math';

import 'package:vector_math/vector_math.dart';

final _rand =  Random(9527);

Vector2 nextV() {
  int x = _rand.nextInt(4);
  switch(x) {
    case 0:
      return Vector2(1.0, 0.0);
    case 1:
      return Vector2(-1.0, 0.0);
    case 2:
      return Vector2(0.0, 1.0);
    case 3:
      return Vector2(0.0, -1.0);
    default:
      return Vector2.zero();
  }
}
