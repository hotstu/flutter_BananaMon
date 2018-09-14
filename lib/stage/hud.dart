import 'dart:ui';
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../lib/flutter/projection.dart';

class HUD {
  Rect d;
  Paint p;
  final w = 192.0;
  final padding = 32.0;

  final Context c;

  HUD(this.c) {
    Rect outline = Rect.fromLTWH(-.5*w, -.5*w, w, w);
    var matrix4 = Matrix4.identity()
      ..translate(padding+.5*w, c.p_height - padding - w+.5*w)
      ..rotateZ(math.pi * 0.25)//顺时针,先于translate
      ; //!后面的先生效
    var lt = matrix4.transform3(Vector3(outline.left, outline.top, 0.0));

    var rd = matrix4.transform3(Vector3(outline.right, outline.bottom, 0.0));
    print('hub draw $lt');
    print('hub draw $rd');
    d = Rect.fromLTRB(lt.x, lt.y, rd.x, rd.y);
    p = Paint();
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 5.0;
    p.color = Color.fromRGBO(255, 0, 0, 1.0);
  }

  draw(Canvas canvas) {

    canvas.drawRect(d, p);
  }

}