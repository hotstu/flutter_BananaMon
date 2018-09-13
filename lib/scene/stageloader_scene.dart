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

  StageLoaderScene(this.game)
      : resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio() {}

  preload() async {
    // load resouce;
    state = Scene.SCENE_STATE_READY;
  }

  _drawOnce() async {
    TimerStream timer = TimerStream(Duration(milliseconds: 30), 10);
    await for (var tick in timer.stream) {
      _drawTranslation(tick / 10);
    }
  }

  /**
   * @Param fraction [0,1]
   */
  _drawTranslation(num fraction) {
    print("draw");
    ctx.setBrush("white");
    ctx.setFont("30px Pokemon regular");
    String msg = "$attr";
    num fontWidth = ctx.measureText(msg);
    ctx.rclearRect(-1, -1);
    ctx.save();
    num transX = ctx.width * .5 - fontWidth * .5;
    num transY = ctx.height * .5 - 50 * .5;
    ctx.translate(transX, transY * fraction);
    ctx.rfillText(0, 0, msg);
    ctx.restore();
  }

  @override
  destroy() {
    state = Scene.SCENE_STATE_DESTORY;
  }

  _openStage() async {
    await delay(Duration(milliseconds: 1000));
    game.start("stage", attr);
  }

  @override
  tick() async {

  }

  @override
  draw(CanvasWrapper ctx) async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      this.ctx = ctx;
      await preload();
      print("start laoder 1");
      await _drawOnce();
      print("start laoder 2");
      await _openStage();
      print("start laoder 3");
      this.ctx = null;
      return;
    }
    print("start laoder 4");

    if (state == Scene.SCENE_STATE_READY) {}
  }

}
