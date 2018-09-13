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

  GameOverScene(this.game)
      : this.keyboard = inject.injectKeyboard(),
        resourceProvider = inject.injectResourceProvider(),
        audio = inject.injectAudio() {}

  preload() async {
    // load resouce;
    keyboard.addListener(this);
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
    ctx.setFont("50px Pokemon Bold");
    String msg = "GAME OVER";
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
    keyboard.removeListener(this);
    state = Scene.SCENE_STATE_DESTORY;
  }

  @override
  tick() async {}

  @override
  draw(CanvasWrapper ctx) async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      this.ctx = ctx;
      await preload();
      await _drawOnce();
      this.ctx = null;
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {}
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
