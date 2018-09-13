import 'package:vector_math/vector_math.dart';

import '../../lib/chess_pad.dart';
import '../../lib/canvas_wrapper.dart';
import '../../lib/rect.dart';
import '../../lib/sprite.dart';


abstract class Property {
  String get name;
  String get type;
  Sprite get sprite;
  double get speed;
  double get iq;
  Rect<num> get rect;

  CanvasWrapper get ctx;
  ChessPad get chessPad;
  Vector2 get v;
}