import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'sprite.dart';

abstract class CanvasWrapper {

  num get height;
  num get width;

  void setFont(String font);

  void save();
  void restore();
  void translate(num x, num y);
  void scale(num x, num y);
  void transform(num a,num b,num c,num d,num e,num f);
  /**
   * @param angle: rad
   */
  void rotate(num angle);

  num measureText(String text);

  void setBrush(String color);

  void clearRect(int x, int y);

  void fillRect(int x, int y);

  void fillText(int x, int y, String text);

  void rfillText(num x, num y, String text,[num maxWidth]);

  void rclearRect(num x, num y);

  void rfillRect(num x, num y);

  void rdrawImage(Sprite drawable, Rectangle<num> rect);

  /**
   * 类似于Math.floor
   */
  Vector2 py2loProjection(Vector2 p);

  /**
   * 左上角重合
   */
  Vector2 lo2pyProjection(Vector2 p);



  String exportBitmap(image);

  List<Sprite> obtainSoureDesc(String type);
}
