import 'dart:ui';

import 'package:vector_math/vector_math.dart';

import 'resourcProvider.dart';
import '../../game.dart';
import '../sprite.dart';
import '../injection.dart' as inject;

class Context {
  final num p_width;
  final num p_height;
  final num l_width;
  final num l_height;
  final num CELL_SIZE_W;
  final num CELL_SIZE_H;
  final ResourceProvider resourceProvider;
  final BaseGame game;

  Context(this.game, this.p_width, this.p_height, this.l_width, this.l_height)
      :resourceProvider = inject.injectResourceProvider(),
        CELL_SIZE_W = 40.0,
        CELL_SIZE_H = 40.0;

  @override
  Vector2 py2loProjection(Vector2 p) {
    num x = (p.x) * l_width ~/ p_width;
    num y = (p.y) * l_height ~/ p_height;
    return Vector2(x, y);
  }

  @override
  Vector2 lo2pyProjection(Vector2 p) {
    num x = (p.x) / l_width * p_width;
    num y = (p.y) / l_height * p_height;
    return Vector2(x, y);
  }

  @override
  List<Sprite> obtainSoureDesc(String type) {
    return resourceProvider.obtainSoureDesc(type);
  }

  Image obtainSoureByName(String name) {
    // all the image source should managed by this instance;
    return resourceProvider.obtainSoureByName(name);
  }
}