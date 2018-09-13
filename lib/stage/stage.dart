import 'dart:async';

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
import '../lib/injection.dart' as inject;
import '../lib/constants.dart' as constants;

class Stage extends Scene {
  final LevelProvider levelProvider;
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

  Stage(this._game)
      : levelProvider = inject.injectLevelProvider(),
        audio = inject.injectAudio();

  Future _init() async {
    //800*600 40*40
    assert(attr != null);
    level = attr;
    sm = await levelProvider.obtain(level);
    chessPad = new ChessPad(canvas, sm.width, sm.height); //按区块存储char，便于快速查询
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
          var softWallBlock = WeakBrick("block${i}-${j}", canvas, this, i, j);
          wallList1.add(softWallBlock);
        } else if (wallPhase == 0xff) {
          //wall2;
          var wallBlock = Brick("block${i}-${j}", canvas, this, i, j);
          wallList2.add(wallBlock);
        }
        var monsterPhase = sm.monsterPhase[i][j];
        if (monsterPhase > 0) {
          int monsterType = (monsterPhase & 0xf0) ~/ 0x10;
          int monsterCount = monsterPhase & 0x0f;
          print("${monsterPhase} -${monsterType} -$monsterCount");
          switch (monsterType) {
            case 0:
              heroList.add(Hero("hero${i}-${j}", canvas, this, i, j));
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
                monsterList
                    .add(Monster("monster${i}-${j}-${k}", canvas, this, i, j));
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
              treasureList.add(TreasureGate("tr${i}-${j}", canvas, this, i, j));
              break;
            case 1:
              treasureList
                  .add(TreasureBombCountUp("tr${i}-${j}", canvas, this, i, j));
              break;
            case 2:
              treasureList
                  .add(TreasurePowerUp("tr${i}-${j}", canvas, this, i, j));
              break;
            case 3:
              treasureList
                  .add(TreasureSpeedUp("tr${i}-${j}", canvas, this, i, j));
              break;
            case 4:
              treasureList.add(
                  TreasureBombType("tr${i}-${j}", canvas, this, "2", i, j));
              break;

            default:
              break;
          }
        }
      }
    }
    print(heroList.length);
    print(wallList1.length);
    print(wallList2.length);
    print(monsterList.length);
    audio.play("starting");
    await delay(Duration(milliseconds: 2000));
    bgmPlay = audio.play("playing", true);
    state = Scene.SCENE_STATE_READY;
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
      await _init();
      return;
    }
    if(!_paused) {
      _think();
    }
  }

  draw(CanvasWrapper ctx) {
    this.canvas = ctx;
    _draw();
    this.canvas = null;
  }

  add(BaseChar char) async {
    return Future.delayed(Duration.zero).then((_) {
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
    });
  }

  remove(BaseChar char) async {
    return Future.delayed(Duration.zero).then((_) {
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
    });
  }

  void _draw() {
    //now only support one player!
    canvas.rclearRect(-1, -1);
    wallList2.forEach((item) => item.draw());
    treasureList.forEach((item) => item.draw());
    wallList1.forEach((item) => item.draw());
    expList.forEach((item) => item.draw());
    bombList.forEach((item) => item.draw());
    monsterList.forEach((item) => item.draw());
    heroList.forEach((item) => item.draw());
  }

  void _think() {
    heroList.forEach((item) => item.tick());
    //wallList2.forEach((item) => item.tick());
    wallList1.forEach((item) => item.tick());
    monsterList.forEach((item) => item.tick());
    bombList.forEach((item) => item.tick());
    expList.forEach((item) => item.tick());
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
    bgmPlay?.stop();
    new List.from(wallList1).forEach((e) => e?.destroy(false));
    new List.from(treasureList).forEach((e) => e?.destroy(false));
    new List.from(wallList2).forEach((e) => e?.destroy(false));
    new List.from(monsterList).forEach((e) => e?.destroy(false));
    new List.from(heroList).forEach((e) => e?.destroy(false));
    new List.from(bombList).forEach((e) => e?.destroy(false));
    new List.from(expList).forEach((e) => e?.destroy(false));
    state = Scene.SCENE_STATE_DESTORY;
  }

  @override
  GameHandler get game => (_game);
}
