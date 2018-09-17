import 'dart:math';
import 'dart:ui' hide TextStyle;

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart';

import '../canvas_wrapper.dart' as base;
import '../sprite.dart';
import 'color_parser.dart';
import 'projection.dart';


class CanvasWrapper implements base.CanvasWrapper {
  final Context C;

  Paint _clearPaint;
  Canvas ctx;
  Paint _colorPaint;
  Paint _tilePaint;
  TextPainter _textPainter;
  Color _textColor;
  String _textFont;
  num _textSize = 25.0;
  bool _dirty = true;
  String _lastText;

  CanvasWrapper(this.ctx, this.C) {
    _clearPaint = Paint();
    _clearPaint.blendMode = BlendMode.clear;
    _clearPaint.style = PaintingStyle.fill;
    _colorPaint = Paint();
    _colorPaint.blendMode = BlendMode.src;
    _colorPaint.style = PaintingStyle.fill;
    _tilePaint = Paint();
    _tilePaint.blendMode = BlendMode.srcATop;
    _tilePaint.style = PaintingStyle.fill;
  }

  @override
  void setBrush(String colorstr) {
    var color = ColorParser(colorstr);
    _colorPaint.color = color;
    if (_textColor != color) {
      _textColor = color;
      _dirty = true;
    }
  }

  _ensureTextPaint(String text) {
    if (_textPainter == null || _dirty || _lastText != text) {
      _dirty = false;
      _lastText = text;
      _textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: _textFont,
                fontSize: _textSize,
                color: _textColor,
              ))
      );
    }
  }


  @override
  num measureText(String text) {
    _ensureTextPaint(text);
    _textPainter.layout();
    return _textPainter.width;
  }

  @override
  void setFont(String font) {
    if (_textFont != font) {
      _textFont = font;
      _dirty = true;
    }
  }

  @override
  void clearRect(int x, int y) {
    var pyP = C.lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.drawRect(Rect.fromLTWH(
        pyP.x, pyP.y, C.CELL_SIZE_W.toDouble(), C.CELL_SIZE_H.toDouble()),
        _clearPaint);
  }

  @override
  void fillRect(int x, int y) {
    var pyP = C.lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.drawRect(Rect.fromLTWH(
        pyP.x, pyP.y, C.CELL_SIZE_W.toDouble(), C.CELL_SIZE_H.toDouble()),
        _colorPaint);
  }

  @override
  void fillText(int x, int y, String text) {
    var pyP = C.lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.save();
    ctx.translate(-(pyP.x + .5 * C.CELL_SIZE_W), -(pyP.y + .5 * C.CELL_SIZE_H));
    _ensureTextPaint(text);
    _textPainter.paint(ctx, Offset.zero);
    ctx.restore();
  }

  @override
  void rfillText(num x, num y, String text, [num maxWidth]) {
    ctx.save();
    ctx.translate(-x.toDouble(), -y.toDouble());
    _ensureTextPaint(text);
    _textPainter.paint(ctx, Offset.zero);
    ctx.restore();
  }


  @override
  void rclearRect(num x, num y) {
    if (x == -1 && y == -1) {
      ctx.drawRect(
          Rect.fromLTWH(0.0, 0.0, C.p_width.toDouble(), C.p_height.toDouble()),
          _clearPaint);
    } else {
      ctx.drawRect(Rect.fromLTWH(
          x.toDouble(), y.toDouble(), C.CELL_SIZE_W.toDouble(),
          C.CELL_SIZE_H.toDouble()), _clearPaint);
    }
  }

  @override
  void rfillRect(num x, num y) {
    ctx.drawRect(Rect.fromLTWH(
        x.toDouble(), y.toDouble(), C.CELL_SIZE_W.toDouble(),
        C.CELL_SIZE_H.toDouble()), _colorPaint);
  }

  @override
  void rdrawImage(Sprite drawable, Rectangle<num> rect) {
    Rect srcRect = Rect.fromLTWH(
        drawable.rect.left.toDouble(),
        drawable.rect.top.toDouble(),
        drawable.rect.width.toDouble(),
        drawable.rect.height.toDouble());
    Rect dRect = Rect.fromLTWH(
        rect.left + drawable.dst.left + .0,
        rect.top + drawable.dst.top + .0,
        drawable.dst.width <= 0 ? C.CELL_SIZE_W.toDouble() : drawable.dst.width
            .toDouble(),
        drawable.dst.height <= 0 ? C.CELL_SIZE_H.toDouble() : drawable.dst
            .height.toDouble());
    ctx.drawImageRect(
        C.obtainSoureByName(drawable.sourceId), srcRect, dRect, _tilePaint);
  }


  @override
  void restore() {
    ctx.restore();
  }

  @override
  void save() {
    ctx.save();
  }

  @override
  void translate(num x, num y) {
    ctx.translate(x + .0, y + .0);
  }

  @override
  void scale(num x, num y) {
    ctx.scale(x + .0, y + .0);
  }

  @override
  void transform(num a, num b, num c, num d, num e, num f) {
    //TODO not support yet
  }

  @override
  void rotate(num angle) {
    ctx.rotate(angle + .0);
  }

  @override
  num get height => C.p_height;

  @override
  num get width => C.p_width;

  @override
  String exportBitmap(v) {
    return "not support in flutter";
  }
}
