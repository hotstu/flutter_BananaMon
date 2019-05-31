import 'dart:async';
import 'dart:collection';
import 'dart:ui' hide TextStyle;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'lib/flutter/canvas_wrapper.dart';
import 'scene/gameover_scene.dart';
import 'scene/stageloader_scene.dart';
import 'scene/title_scene.dart';
import 'stage/stage.dart';
import 'lib/flutter/projection.dart';
import 'lib/game_handler.dart';
import 'lib/injection.dart' as inject;
import 'lib/constants.dart' as constatns;
import 'stage/hud.dart';


class MyGame extends BaseGame {
  bool started;

  Map<String, dynamic> map;
  String senceName;
  Context context;
  HUD hud;
  CanvasWrapper wrapper;
  MyGameHandler handler;
  MyGame() {
    started = false;
    map = new HashMap();
    context = Context(this, 1240, 600, constatns.logicalWidth, constatns.logicalHeight);
    hud = HUD(context);
    wrapper = CanvasWrapper(null, context);
  }


  @override
  void destroy() {
    handler?.destroy();
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    print('lifecycleStateChange$state');
    if(state == AppLifecycleState.paused) {
      handler?.pause();
    }
    if(state == AppLifecycleState.resumed) {
      handler?.resume();
    }
  }


  _renderFps(Canvas canvas) {
    TextPainter tp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            style: TextStyle(
              color: Colors.green,
              fontSize: 20.0,
            ),
            text: "${fps(10).toInt()}"
        )
    );
    tp.layout();
    tp.paint(canvas, Offset.zero);
  }

  @override
  bool debugMode() => true;

  @override
  render(Canvas canvas) {
    canvas.save();
    num sx = size.width / context.p_width;
    num sy = size.height / context.p_height;
    //print("reander $size");
    canvas.scale(sx, sy);
    wrapper.ctx = canvas;
    map[senceName]?.draw(wrapper);
    hud.draw(canvas);
    canvas.restore();
    if (debugMode()) {
      //canvas.translate(0.0, 25.0);
      _renderFps(canvas);
    }
  }

  @override
  Future update(double t) async {
    // print('update at ${lastEslapedtime} - ${delta}' );
    if (started) {
      return await map[senceName]?.tick();
    }
  }


}

class MyGameHandler extends GameHandler {
  final MyGame game;

  MyGameHandler(this.game);

  @override
  void add(String name, dynamic scene) {
    game.map[name] = scene;
  }

  @override
  void pause() {
    game.started = false;
    game.map[game.senceName]?.pause();
  }

  @override
  void resume() {
    game.map[game.senceName]?.resume();
    game.started = true;
  }

  @override
  void destroy() {
    //TODO there would be a pain if we can't hook destory event in flutter?
    game.map[game.senceName]?.destroy();
    game.started = false;
  }

  @override
  void start(String name, [attr]) {
    print("start scene $name, attr=$attr");
    game.map[game.senceName]?.destroy();
    game.senceName = name;
    game.map[game.senceName]?.reset(attr);
    //game.map[game.senceName]?.resume();
    game.started = true;
  }
}


Future main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);
  MyGame game = MyGame();
  MyGameHandler iGame = MyGameHandler(game);
  game.handler = iGame;
  TitleScene title = TitleScene(iGame);
  Stage stage = Stage(iGame, game.context);
  GameOverScene over = GameOverScene(iGame);
  StageLoaderScene loader = StageLoaderScene(iGame);
  iGame.add("title", title);
  iGame.add("stage", stage);
  iGame.add("over", over);
  iGame.add("loader", loader);
  runApp(game.widget);
  iGame.start("title");
  inject.injectKeyboard().start();
}



