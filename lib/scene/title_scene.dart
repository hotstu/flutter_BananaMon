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

class TitleScene extends Scene with KeyBoardWatcher {
  GameHandler game;
  int state = Scene.SCENE_STATE_INT;
  ResourceProvider resourceProvider;
  Keyboard keyboard;
  AudioManager audio;
  SoundPlay bgm;
  Object lock;
  num fraction;

  TitleScene(this.game)
      : this.keyboard = inject.injectKeyboard(),
        resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio();

  Future preload() async {
    // load resouce;
    int current = 0;
    int total = 11 + 8; //对应resoureProvider+audioManager资源总量
    await for (var i in audio.init()) {
      current += 1;
      fraction = current/total;
    }
    await for (var i in resourceProvider.init()) {
      current += 1;
      fraction = current/total;
    }
    keyboard.init();
    keyboard.addListener(this);
    bgm = await audio.play("opening", true);
  }

  _drawProgress(CanvasWrapper ctx) {
    double f = fraction??0.0;

    int progress = (f * 100).round();
    String msg = "loading...%${progress}";
    print(msg);
    int fontHeight = 50;
    ctx.setBrush("#fff");
    ctx.setFont("${fontHeight}px Pokemon Bold");
    num fontWidth = ctx.measureText(msg);
    ctx.rclearRect(-1, -1);
    ctx.save();
    num transX = ctx.width * .5 - fontWidth * .5;
    num transY = ctx.height * .5 - fontHeight * .5;
    ctx.translate(transX, transY);
    ctx.rfillText(0, 0, msg);
    ctx.restore();
  }

  _drawOnce() async {
    TimerStream timer = TimerStream(Duration(milliseconds: 30), 10);
    await for (var tick in timer.stream) {
      fraction =  (tick + 1) / 10;
    }
  }

  /**
   * @Param fraction [0,1]
   */
  _drawTranslation(CanvasWrapper ctx ) {
    double f = fraction??0.0;

    ctx.setBrush("#fff");
    ctx.setFont("50px Pokemon Bold");
    String msg = "BananaMon";
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
    bgm.release();
    keyboard.removeListener(this);
    state = Scene.SCENE_STATE_DESTORY;
    lock = null;
  }

  @override
  void pause() {
    print('title pause');
    bgm?.stop();
  }


  @override
  void resume() {
    print('title resume');
    bgm?.start();
  }

  @override
  tick() {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if (lock != null) {
        return;
      }
      lock = 1;
      fraction = 0.0;
      preload().then((_) {
        lock = 2;
        return _drawOnce();
      }).then((_) {
        state = Scene.SCENE_STATE_READY;
      });
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {
      return;
    }
  }

  draw(CanvasWrapper ctx) async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if(lock == 1) {
        _drawProgress(ctx);
      }
      else if(lock == 2) {
        _drawTranslation(ctx);
      }
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {
      _drawTranslation(ctx);
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
