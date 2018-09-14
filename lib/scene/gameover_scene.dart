import 'dart:async';

import '../lib/flutter/resourcProvider.dart';

import '../char/mixin/keyboardWatcher.dart';
import '../lib/audio_manager.dart';
import '../lib/canvas_wrapper.dart';
import '../lib/game_handler.dart';
import '../lib/keyboard.dart';
import 'scene.dart';
import '../lib/timer_stream.dart';
import '../lib/injection.dart' as inject;

class GameOverScene extends Scene with KeyBoardWatcher {
  GameHandler game;
  ResourceProvider resourceProvider;
  CanvasWrapper ctx;
  Keyboard keyboard;
  AudioManager audio;
  num fraction;
  Object lock;

  GameOverScene(this.game)
      : this.keyboard = inject.injectKeyboard(),
        resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio() {}

  Future preload() async {
    // load resouce;
    keyboard.addListener(this);
  }

  _drawOnce() async {
    TimerStream timer = TimerStream(Duration(milliseconds: 30), 10);
    await for (var tick in timer.stream) {
      fraction = ((tick + 1) / 10);
    }
  }

  /**
   * @Param fraction [0,1]
   */
  _drawTranslation() {
    double f = fraction??0.0;
    ctx.setBrush("#fff");
    ctx.setFont("50px Pokemon Bold");
    String msg = "GAME OVER";
    num fontWidth = ctx.measureText(msg);
    ctx.rclearRect(-1, -1);
    ctx.save();
    num transX = ctx.width * .5 - fontWidth * .5;
    num transY = ctx.height * .5 - 50 * .5;
    ctx.translate(transX, transY * f);
    ctx.rfillText(0, 0, msg);
    ctx.restore();
    ctx.setFont("30px Pokemon regular");
    String msg2 = "press anykey to start";
    String msg3 = "© 2018 hglf@github All Rights Reserved";
    ctx.save();
    ctx.setBrush("rgba(255,255,255,${0.8 * f})");
    fontWidth = ctx.measureText(msg2);
    ctx.translate(ctx.width * .5 - fontWidth * .5, ctx.height - 100);
    ctx.rfillText(0, 0, msg2);
    ctx.restore();
    ctx.save();
    ctx.setBrush("rgba(255,255,255,${0.8 * f})");
    fontWidth = ctx.measureText(msg3);
    ctx.translate(ctx.width * .5 - fontWidth * .5, ctx.height - 60);
    ctx.rfillText(0, 0, msg3);
    ctx.restore();
  }

  @override
  destroy() {
    keyboard.removeListener(this);
    state = Scene.SCENE_STATE_DESTORY;
    lock = null;
  }

  @override
  tick() async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if(lock == null) {
        lock  = 1;
        preload()
            .then((_) => _drawOnce())
        .then((_) {
          state = Scene.SCENE_STATE_READY;
        });
      }
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {

    }
  }

  @override
  draw(CanvasWrapper ctx) async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if(lock != null) {
        this.ctx = ctx;
        _drawTranslation();
        this.ctx = null;
      }
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {
      this.ctx = ctx;
      _drawTranslation();
      this.ctx = null;
    }
  }

  @override
  onKeyDown(keyCode) {
    //any key press
    destroy();
    game.start("loader", "s1");
  }

  @override
  onKeyUp(keyCode) {
    // TODO: implement onKeyUp
  }

}
