import 'package:vector_math/vector_math.dart';

import '../../lib/chess_pad.dart';
import '../../lib/rect.dart';
import '../../lib/sprite.dart';
import '../../lib/flutter/projection.dart';


abstract class Property {
  String get name;
  String get type;
  Sprite get sprite;
  double get speed;
  double get iq;
  Rect<num> get rect;

  Context get ctx;
  ChessPad get chessPad;
  Vector2 get v;
}