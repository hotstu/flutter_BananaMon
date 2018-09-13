import 'dart:math';

class Sprite {
  final String sourceId;
  final Rectangle<int> rect;
  final Rectangle<int> dst;

  Sprite.fromValues(this.sourceId, num left, num top, num width, num height,
      num dstLeft, num dstTop, num dstWidth, num dstHeight)
      : rect = Rectangle(left, top, width, height),
        dst = Rectangle(dstLeft, dstTop, dstWidth, dstHeight);
}
