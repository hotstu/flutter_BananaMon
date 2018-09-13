import 'dart:math';
import 'dart:ui' hide TextStyle;

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart';

import 'resourcProvider.dart';
import '../canvas_wrapper.dart' as base;
import '../sprite.dart';
import '../injection.dart' as inject;
import 'color_parser.dart';


class CanvasWrapper implements base.CanvasWrapper {
  final Canvas ctx;
  final ResourceProvider resourceProvider;
  final num p_width;
  final num p_height;
  final num l_width;
  final num l_height;
  final num CELL_SIZE_W;
  final num CELL_SIZE_H;

  Paint _clearPaint;
  Paint _colorPaint;
  TextPainter _textPainter;
  Color _textColor;
  String _textFont;
  num _textSize;
  bool _dirty = true;
  String _lastText;


  CanvasWrapper(this.ctx, Size size, this.l_height, this.l_width)
      : p_width = size.width,
        p_height = size.height,
        resourceProvider = inject.injectResourceProvider(),
        CELL_SIZE_W = 40.0,
        CELL_SIZE_H = 40.0 {
    _clearPaint = Paint();
    _clearPaint.blendMode = BlendMode.clear;
    _clearPaint.style = PaintingStyle.fill;
    _colorPaint = Paint();
    _colorPaint.blendMode = BlendMode.src;
    _colorPaint.style = PaintingStyle.fill;
  }

  @override
  void setBrush(String colorstr) {
    var color = ColorParser(colorstr);
    _colorPaint.color = color;
    if(_textColor != color) {
      _textColor = color;
      _dirty = true;
    }
  }

  _ensureTextPaint(String text) {
    if(_textPainter == null || _dirty|| _lastText != text) {
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
    if(_textFont != font) {
      _textFont = font;
      _dirty = true;
    }

  }

  @override
  void clearRect(int x, int y) {
    var pyP = lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.drawRect(Rect.fromLTWH(pyP.x, pyP.y, CELL_SIZE_W.toDouble(), CELL_SIZE_H.toDouble()), _clearPaint);
  }

  @override
  void fillRect(int x, int y) {
    var pyP = lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.drawRect(Rect.fromLTWH(pyP.x, pyP.y, CELL_SIZE_W.toDouble(), CELL_SIZE_H.toDouble()), _colorPaint);
  }

  @override
  void fillText(int x, int y, String text) {
    var pyP = lo2pyProjection(Vector2(x.toDouble(), y.toDouble()));
    ctx.save();
    ctx.translate(-(pyP.x + .5 * CELL_SIZE_W), -(pyP.y + .5 * CELL_SIZE_H));
    _ensureTextPaint(text);
    _textPainter.paint(ctx, Offset.zero);
    ctx.restore();
  }

  @override
  void rfillText(num x, num y, String text, [num maxWidth]) {
    ctx.save();
    ctx.translate(-x.toDouble() , -y.toDouble());
    _ensureTextPaint(text);
    _textPainter.paint(ctx, Offset.zero);
    ctx.restore();
  }

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


  String exportBitmap(image) {
    return "not support";
  }

  @override
  void rclearRect(num x, num y) {
    if (x == -1 && y == -1) {
      ctx.drawRect(Rect.fromLTWH(0.0, 0.0, p_width.toDouble(), p_height.toDouble()), _clearPaint);
    } else {
      ctx.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), CELL_SIZE_W.toDouble(), CELL_SIZE_H.toDouble()),_clearPaint);
    }
  }

  @override
  void rfillRect(num x, num y) {
    ctx.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), CELL_SIZE_W.toDouble(), CELL_SIZE_H.toDouble()), _colorPaint);
  }

  Image _obtainSoureByName(String name) {
    // all the image source should managed by this instance;
    return resourceProvider.obtainSoureByName(name);
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
        drawable.dst.width <= 0 ? CELL_SIZE_W.toDouble() : drawable.dst.width.toDouble(),
        drawable.dst.height <= 0 ? CELL_SIZE_H.toDouble() : drawable.dst.height.toDouble());
    ctx.drawImageRect(_obtainSoureByName(drawable.sourceId), srcRect, dRect, _colorPaint);

  }

  @override
  List<Sprite> obtainSoureDesc(String type) {
    return resourceProvider.obtainSoureDesc(type);
  }

  @override
  num get height => p_height;

  @override
  num get width => p_width;

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
}
