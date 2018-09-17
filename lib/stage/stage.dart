import 'dart:async';
import 'dart:ui' hide Scene;

import 'package:flutter/material.dart' hide Hero;

import '../char/base_char.dart';
import '../char/bomb.dart';
import '../char/explosion.dart';
import '../char/hero.dart';
import '../char/monster.dart';
import '../char/brick.dart';
import '../char/treasure.dart';
import '../lib/audio_manager.dart';
import '../lib/chess_pad.dart';
import '../lib/canvas_wrapper.dart';
import '../lib/game_handler.dart';
import '../scene/scene.dart';
import '../lib/level_provider.dart';
import '../lib/timer_stream.dart';
import 'stage_model.dart';
import '../lib/flutter/projection.dart';
import '../lib/injection.dart' as inject;
import '../lib/constants.dart' as constants;
import '../lib/flutter/canvas_wrapper.dart' as impl;

class Stage extends Scene {
  final LevelProvider levelProvider;
  final Context context;

  CanvasWrapper canvas;
  String level;

  List<WeakBrick> wallList1 = [];
  List<Brick> wallList2 = [];
  List<Monster> monsterList = [];
  List<Hero> heroList = [];
  List<Bomb> bombList = [];
  List<Explosion> expList = [];
  List<Treasure> treasureList = [];
  StageModel sm;
  ChessPad chessPad;
  AudioManager audio;
  SoundPlay bgmPlay;
  GameHandler _game;
  Paint staticPaint;
  Object tickLock;

  Stage(this._game, this.context)
      : levelProvider = inject.injectLevelProvider(),
        audio = inject.injectAudio();

  Future _init() async {
    //800*600 40*40
    assert(attr != null);
    level = attr;
    sm = await levelProvider.obtain(level);
    chessPad = new ChessPad(context, sm.width, sm.height); //按区块存储char，便于快速查询
    wallList1 = [];
    wallList2 = [];
    monsterList = [];
    heroList = [];
    bombList = [];
    expList = [];
    for (var i = 0; i < sm.width; ++i) {
      for (var j = 0; j < sm.height; ++j) {
        var wallPhase = sm.wallPhase[i][j];
        if (wallPhase == 0x7f) {
          //wall1;
          var softWallBlock = WeakBrick("block${i}-${j}", context, this, i, j);
          wallList1.add(softWallBlock);
        } else if (wallPhase == 0xff) {
          //wall2;
          var wallBlock = Brick("block${i}-${j}", context, this, i, j);
          wallList2.add(wallBlock);
        }
        var monsterPhase = sm.monsterPhase[i][j];
        if (monsterPhase > 0) {
          int monsterType = (monsterPhase & 0xf0) ~/ 0x10;
          int monsterCount = monsterPhase & 0x0f;
          print("${monsterPhase} -${monsterType} -$monsterCount");
          switch (monsterType) {
            case 0:
              heroList.add(Hero("hero${i}-${j}", context, this, i, j));
              break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
              for (var k = 0; k < monsterCount; ++k) {
                monsterList.add(Monster("monster${i}-${j}-${k}", context, this, i, j));
              }
              break;
            default:
              break;
          }
        }
        var treasurePhase = sm.treasurePhase[i][j];
        if (treasurePhase > 0) {
          int treasureType = (treasurePhase & 0xf0) ~/ 0x10;
          switch (treasureType) {
            case 0:
              treasureList.add(
                  TreasureGate("tr${i}-${j}", context, this, i, j));
              break;
            case 1:
              treasureList.add(
                  TreasureBombCountUp("tr${i}-${j}", context, this, i, j));
              break;
            case 2:
              treasureList.add(
                  TreasurePowerUp("tr${i}-${j}", context, this, i, j));
              break;
            case 3:
              treasureList.add(
                  TreasureSpeedUp("tr${i}-${j}", context, this, i, j));
              break;
            case 4:
              treasureList.add(
                  TreasureBombType("tr${i}-${j}", context, this, "2", i, j));
              break;

            default:
              break;
          }
        }
      }
    }
    print("init tr = ${treasureList.length}");
    print("init mo = ${monsterList.length}");
    print("init w2 = ${wallList2.length}");
    print("init w1 = ${wallList1.length}");
    audio.play("starting");
    await delay(Duration(milliseconds: 2000));
    bgmPlay = await audio.play("playing", true);
    state = Scene.SCENE_STATE_READY;
    tickLock = null;
  }

  bool _paused = false;

  @override
  void pause() {
    _paused = true;
  }


  @override
  void resume() {
    _paused = false;
  }

  tick() async {
    if (state == Scene.SCENE_STATE_DESTORY) {
      return;
    }
    if (state == Scene.SCENE_STATE_INT) {
      if(tickLock == null) {
        tickLock = 1;
        await _init();
      }
      return;
    }
    if (state == Scene.SCENE_STATE_READY) {
      if (!_paused) {
        _think();
      }
    }

  }

  draw(CanvasWrapper ctx) {
    if (state == Scene.SCENE_STATE_READY) {
      this.canvas = ctx;
      if(staticPaint == null) {
        _drawStatic();
      }
      _draw();
      this.canvas = null;
    }

  }

  add(BaseChar char) {
    if (char is WeakBrick) {
      if (!wallList1.contains(char)) {
        wallList1.add(char);
      }
      return;
    }
    if (char is Block) {
      if (!wallList2.contains(char)) {
        wallList2.add(char);
      }
      return;
    }
    if (char is Monster) {
      if (!monsterList.contains(char)) {
        monsterList.add(char);
      }
      return;
    }
    if (char is Hero) {
      if (!heroList.contains(char)) {
        heroList.add(char);
      }
      return;
    }
    if (char is Bomb) {
      if (!bombList.contains(char)) {
        bombList.add(char);
      }
      return;
    }
    if (char is Explosion) {
      if (!expList.contains(char)) {
        expList.add(char);
      }
      return;
    }
    if (char is Treasure) {
      if (!treasureList.contains(char)) {
        treasureList.add(char);
      }
      return;
    }
  }

  remove(BaseChar char) {
    if (char is WeakBrick) {
      wallList1.remove(char);
      return;
    }
    if (char is Block) {
      wallList2.remove(char);
      return;
    }
    if (char is Monster) {
      monsterList.remove(char);
      return;
    }
    if (char is Hero) {
      heroList.remove(char);
      return;
    }
    if (char is Bomb) {
      bombList.remove(char);
      return;
    }
    if (char is Explosion) {
      expList.remove(char);
      return;
    }
    if (char is Treasure) {
      treasureList.remove(char);
      return;
    }
  }

  void _draw() {
    //now only support one player!
    //canvas.rclearRect(-1, -1);
    //print('treasure count ${treasureList.length}');
    //var d = DateTime.now().microsecondsSinceEpoch.toDouble();
    // draw staticPaint;
    var canvasimpl = canvas as impl.CanvasWrapper;
    canvasimpl.ctx.drawPaint(staticPaint);

    treasureList.forEach((item) => item.draw(canvas));
    wallList1.forEach((item) => item.draw(canvas));
    expList.forEach((item) => item.draw(canvas));
    bombList.forEach((item) => item.draw(canvas));
    monsterList.forEach((item) => item.draw(canvas));
    heroList.forEach((item) => item.draw(canvas));
   // print("_draw cost ${DateTime.now().microsecondsSinceEpoch.toDouble() - d}");
  }

  /**
   * 这个方法破坏了抽象，只对flutter有用，
   */
  void _drawStatic() {
    PictureRecorder rec = PictureRecorder();
    Canvas rawCanvas = Canvas(rec,Rect.fromLTWH(0.0, 0.0, context.p_width.toDouble(), context.p_height.toDouble()));
    rawCanvas.drawColor(Colors.brown, BlendMode.src);
    CanvasWrapper stageCanvas = impl.CanvasWrapper(rawCanvas, context);
    wallList2.forEach((item) => item.draw(stageCanvas));
    Picture picture = rec.endRecording();
    staticPaint = Paint();
    staticPaint.shader = ImageShader(picture.toImage(context.p_width.toInt(), context.p_height.toInt()),
        TileMode.clamp, TileMode.clamp, Matrix4.identity().storage);
  }

  void _think() {
    //var d = DateTime.now().microsecondsSinceEpoch.toDouble();
    List.from(heroList, growable: false).forEach((item) => item.tick());
    //wallList2.forEach((item) => item.tick());
    List.from(wallList1, growable: false).forEach((item) => item.tick());
    List.from(monsterList, growable: false).forEach((item) => item.tick());
    List.from(bombList, growable: false).forEach((item) => item.tick());
    List.from(expList, growable: false).forEach((item) => item.tick());
    //print("tick cost ${DateTime.now().microsecondsSinceEpoch.toDouble() - d}");
  }

  Future _ifWin() async {
    if (0 == monsterList?.length) {
      print("game complete!");
      game.pause();
      audio.play(AudioManager.stageComplete);
      await delay(Duration(milliseconds: 2000));
      var indexOf = LevelProvider.levels.indexOf(attr);
      print("$indexOf, ${LevelProvider.levels.length}");

      if (indexOf + 1 < LevelProvider.levels.length) {
        game.start("loader", LevelProvider.levels[indexOf + 1]);
      } else {
        game.start("title");
      }
      return true;
    }
    return false;
  }

  onEvent(event, data) async {
    if (event == constants.eventOnDestroy) {
      if (data is Hero) {
        print("$data dead");
        audio.play(AudioManager.lifLost);
        HeroBuff().reset();
        await delay(Duration(milliseconds: 2000));
        //go to gameover screen
        game.start("over");
      }
      if (data is Monster) {
        //TODO 统计数量，如果== 0；?
        //print("${monsterList?.length} monsters left.");

      }
    }
    if (event == constants.eventLevelComplte) {
      await _ifWin();
    }
  }

  @override
  void destroy() {
    bgmPlay?.release();
    List.from(wallList1, growable: false).forEach((e) => e?.destroy(false));
    List.from(treasureList, growable: false).forEach((e) => e?.destroy(false));
    List.from(wallList2, growable: false).forEach((e) => e?.destroy(false));
    List.from(monsterList, growable: false).forEach((e) => e?.destroy(false));
    List.from(heroList, growable: false).forEach((e) => e?.destroy(false));
    List.from(bombList, growable: false).forEach((e) => e?.destroy(false));
    List.from(expList, growable: false).forEach((e) => e?.destroy(false));
    state = Scene.SCENE_STATE_DESTORY;
    tickLock = null;
    staticPaint = null;
  }

  @override
  GameHandler get game => (_game);
}
