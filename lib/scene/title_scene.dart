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

  TitleScene(this.game)
      : this.keyboard = inject.injectKeyboard(),
        resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio();

  preload(CanvasWrapper ctx) async {
    // load resouce;
    int current = 0;
    int total = 11 + 8; //对应resoureProvider+audioManager资源总量
    _drawProgress(ctx, current, total);
    await for (var i in audio.init()) {
      current += 1;
      _drawProgress(ctx, current, total);
    }
    await for (var i in resourceProvider.init()) {
      current += 1;
      _drawProgress(ctx, current, total);
    }
    keyboard.addListener(this);
    bgm = audio.play("opening", true);
    state = Scene.SCENE_STATE_READY;
  }

  _drawProgress(CanvasWrapper ctx, current, total) {
    int progress = (current / total * 100).round();
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

  _drawOnce(CanvasWrapper ctx) async {
    TimerStream timer = TimerStream(Duration(milliseconds: 30), 10);
    await for (var tick in timer.stream) {
      _drawTranslation(ctx, tick / 10);
    }
  }

  /**
   * @Param fraction [0,1]
   */
  _drawTranslation(CanvasWrapper ctx, num fraction) {
    print("draw");
    ctx.setBrush("white");
    ctx.setFont("50px Pokemon Bold");
    String msg = "BananaMon";
    num fontWidth = ctx.measureText(msg);
    ctx.rclearRect(-1, -1);
    ctx.save();
    num transX = ctx.width * .5 - fontWidth * .5;
    num transY = ctx.height * .5 - 50 * .5;
    ctx.translate(transX, transY * fraction);
    ctx.rfillText(0, 0, msg);
    ctx.restore();
    ctx.setFont("30px Pokemon regular");

    String msg2 = "press anykey to start";
    String msg3 = "© 2018 hglf@github All Rights Reserved";
    ctx.save();
    ctx.setBrush("rgba(255,255,255,${0.8 * fraction})");
    fontWidth = ctx.measureText(msg2);
    ctx.translate(ctx.width * .5 - fontWidth * .5, ctx.height - 100);
    ctx.rfillText(0, 0, msg2);
    ctx.restore();
    ctx.save();
    print(fraction);
    ctx.setBrush("rgba(255,255,255,${0.8 * fraction})");
    fontWidth = ctx.measureText(msg3);
    ctx.translate(ctx.width * .5 - fontWidth * .5, ctx.height - 60);
    ctx.rfillText(0, 0, msg3);
    ctx.restore();
  }

  @override
  destroy() {
    bgm.stop();
    keyboard.removeListener(this);
    state = Scene.SCENE_STATE_DESTORY;
  }

  @override
  tick() async {
    print('"title tick');
  }

  draw(CanvasWrapper ctx) async {
    print('"title draw');
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      await preload(ctx);
      await _drawOnce(ctx);
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {

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
