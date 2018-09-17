import 'dart:async';

import '../lib/flutter/resourcProvider.dart';

import '../lib/audio_manager.dart';
import '../lib/canvas_wrapper.dart';
import '../lib/game_handler.dart';
import 'scene.dart';
import '../lib/timer_stream.dart';
import '../lib/injection.dart' as inject;

class StageLoaderScene extends Scene {
  GameHandler game;
  ResourceProvider resourceProvider;
  CanvasWrapper ctx;
  AudioManager audio;
  num fraction;
  Object lock;

  StageLoaderScene(this.game)
      : resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio();


  Future _drawOnce() async {
    TimerStream timer = TimerStream(Duration(milliseconds: 30), 10);
    await for (var tick in timer.stream) {
      fraction = ((tick + 1) / 10);
    }
  }

  _drawTranslation() {
    //print("draw");
    double f = fraction??0.0;
    ctx.setBrush("#fff");
    ctx.setFont("30px Pokemon regular");
    String msg = "$attr";
    num fontWidth = ctx.measureText(msg);
    ctx.rclearRect(-1, -1);
    ctx.save();
    num transX = ctx.width * .5 - fontWidth * .5;
    num transY = ctx.height * .5 - 50 * .5;
    ctx.translate(transX, transY * f);
    ctx.rfillText(0, 0, msg);
    ctx.restore();
  }

  @override
  destroy() {
    state = Scene.SCENE_STATE_DESTORY;
    lock = null;
  }

  _openStage() async {
    await delay(Duration(milliseconds: 1000));
    game.start("stage", attr);
  }

  @override
  tick() async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if (lock == null) {
        lock = 1;
        _drawOnce().then((_) {
          return _openStage();
        }).then((_) {
          state = Scene.SCENE_STATE_READY;
        });
      }
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {}
  }

  @override
  draw(CanvasWrapper ctx) {

    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      this.ctx = ctx;
      if(lock != null) {
        _drawTranslation();
      }
      this.ctx = null;
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {}
  }

}
