import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math.dart';

import '../lib/flutter/projection.dart';
import '../lib/injection.dart' as inject;
import '../lib/keyboard.dart';
import '../lib/constants.dart' as constants;

class HUD {
  final w = 48.0;
  final padding = 16.0;
  final Context c;
  final Keyboard keyboard;
  Rect d;
  Paint p;
  var callback;

  HUD(this.c): keyboard = inject.injectKeyboard() {
    p = Paint();
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 5.0;
    p.color = Color.fromRGBO(255, 0, 0, 1.0);

    Rect outline = Rect.fromLTWH(-.5*w, -.5*w, w, w);
    var matrix4 = Matrix4.identity()..translate(c.p_width - padding - w, c.p_height - padding - w); //!后面的先生效
    var lt = matrix4.transform3(Vector3(outline.left, outline.top, 0.0));
    var rd = matrix4.transform3(Vector3(outline.right, outline.bottom, 0.0));
    d = Rect.fromLTRB(lt.x, lt.y, rd.x, rd.y);
  }

  initIfNotYet() {
    if (GestureBinding?.instance?.pointerRouter == null) {
      return;
    }
    if (callback != null) {
      return;
    }
    final recognizer = TapGestureRecognizer()
      ..onTapDown = _onTapDown
      ..onTapUp = _onTapUp;
    final dragRecognizer = ImmediateMultiDragGestureRecognizer()
    ..onStart = (offset) => _MyDrag(offset, keyboard);
    callback = (PointerEvent e) {
      final midX = c.game.size.width * .5;
      if (e is PointerDownEvent ) {
        if( e.position.dx > midX) {
          recognizer.addPointer(e);
        } else {
          dragRecognizer.addPointer(e);
        }
      }
    };
    GestureBinding.instance.pointerRouter.addGlobalRoute(callback);
  }

  _onTapDown(TapDownDetails ev) {
    print("onTapDown${ev.globalPosition}");
    keyboard.sendKeyEvent(constants.keyA);
  }

  _onTapUp(TapUpDetails ev) {
    print("_onTapUp${ev.globalPosition}");
    keyboard.sendKeyEvent(constants.keyA, true);
  }


  draw(Canvas canvas) {
    initIfNotYet();
    //canvas.drawRect(d, p);
  }

}

class _MyDrag extends Drag {
  final Offset start;
  final Keyboard keyboard;
  int _lastKeyHold;
  Offset dd;

  _MyDrag(this.start, this.keyboard){
    dd = Offset(0.0, 0.0);
  }

  @override
  void update(DragUpdateDetails details) {
    //print("drag update ${details.delta},${details.globalPosition}");
    num dx = details.delta.dx;
    num dy = details.delta.dy;
    num slop = 5;
    dd = dd.translate(dx, dy);

    if(dd.dx.abs() <= slop && dd.dy.abs() <= slop) {
      return;
    }

    if(dd.dx > slop) {
      if(_lastKeyHold != constants.keyRight) {
        if(keyboard != null) {
          keyboard.sendKeyEvent(_lastKeyHold, true);
        }
        keyboard.sendKeyEvent(constants.keyRight);
        _lastKeyHold = constants.keyRight;

      }
      dd = Offset(0.0, 0.0);
      return;
    }
    if (dd.dx < -slop) {
      if(_lastKeyHold != constants.keyLeft) {
        if(keyboard != null) {
          keyboard.sendKeyEvent(_lastKeyHold, true);
        }
        keyboard.sendKeyEvent(constants.keyLeft);
        _lastKeyHold = constants.keyLeft;

      }
      dd = Offset(0.0, 0.0);
      return;
    }
    if (dd.dy < -slop) {
      if(_lastKeyHold != constants.keyUp) {
        if(keyboard != null) {
          keyboard.sendKeyEvent(_lastKeyHold, true);
        }
        keyboard.sendKeyEvent(constants.keyUp);
        _lastKeyHold = constants.keyUp;
      }
      dd = Offset(0.0, 0.0);
      return;
    }
    if (dd.dy > slop) {
      if(_lastKeyHold != constants.keyDown) {
        if(keyboard != null) {
          keyboard.sendKeyEvent(_lastKeyHold, true);
        }
        keyboard.sendKeyEvent(constants.keyDown);
        _lastKeyHold = constants.keyDown;
      }
      dd = Offset(0.0, 0.0);
      return;
    }
  }

  @override
  void cancel() {
    if(keyboard != null) {
      keyboard.sendKeyEvent(_lastKeyHold, true);
    }
  }

  @override
  void end(DragEndDetails details) {
    if(keyboard != null) {
      keyboard.sendKeyEvent(_lastKeyHold, true);
    }
  }
}

