import 'package:vector_math/vector_math.dart';

import '../lib/audio_manager.dart';
import '../lib/chess_pad.dart';
import '../lib/keyboard.dart';
import '../lib/sprite.dart';
import '../lib/timer_stream.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import 'bomb.dart';
import 'mixin/keyboardWatcher.dart';
import 'mixin/leg.dart';
import 'mixin/property.dart';
import '../lib/constants.dart' as constants;
import '../lib/injection.dart' as inject;
import '../lib/util.dart' as util;
import 'treasure.dart';

class Hero extends BaseChar with KeyBoardWatcher, Leg {
  final Keyboard keyboard;
  List<Sprite> sps;
  List<Sprite> spsDie;
  Animator animator;
  Animator animatorDie;
  AudioManager audio;
  num hp = 999999;
  int state = constants.stateInit;
  num _speed = 5.0;
  int _power = 1;
  int _bombCount = 1;
  List _myBobes;
  HeroBuff _proxy;

  Hero(String name, ctx, Stage stage, [int x = 0, int y = 0])
      : assert(name != null),
        keyboard = inject.injectKeyboard(),
        audio = inject.injectAudio(),
        super(name, ctx, stage, x, y) {
    v = Vector2(0.0, 0.0);
    sps = ctx.obtainSoureDesc(type);
    //speed = x m/s, period = xx ms/m, period = 1000/v;
    animator = Animator([0], 1000 ~/ speed);
    _proxy = HeroBuff();
    _proxy.subscribe(this);
  }

  void applyBuff(Treasure t) {
    t.buff(_proxy);
  }

  @override
  void tick() {
    if (state == constants.stateDestroyed) {
      return;
    }
    if (state == constants.stateDestroying) {
      animatorDie.tick();
      return;
    }
    if (state == constants.stateNormal) {
      if (hp <= 0) {
        _destroying();
      } else {
        current.others
            .where((cha) => cha is Treasure)
            .forEach((item) => applyBuff(item));
        animator.tick();
        move();
      }
      return;
    }
    if (state == constants.stateInit) {
      //开场3秒无敌
      _myBobes = [];
      state = constants.stateNormal;
      keyboard.addListener(this);
      TimerStream(Duration(milliseconds: 3000), 1).stream.listen((_) {
        hp = 1;
      });
    }
  }

  @override
  Property get property => this;

  @override
  BaseChar get delegate => this;

  @override
  double get iq => 100.0;

  @override
  double get speed => _speed;

  set speed(v) {
    _speed = v;
    animator.peroid = (1000 ~/ _speed);
  }

  @override
  String get type => constants.sourceIdHero1;

  @override
  Sprite get sprite {
    if (state == constants.stateDestroying) {
      return spsDie[animatorDie.index];
    }
    return sps[animator.index];
  }

  _destroying() {
    state = constants.stateDestroying;
    v = Vector2.zero();
    spsDie = ctx.obtainSoureDesc(constants.sourceIdDestory2);
    animatorDie = Animator([1, 2, 3, 4, 5], 100, false, this);
  }

  @override
  void destroy([bool sendEvent = true]) {
    state = constants.stateDestroyed;
    keyboard.removeListener(this);
    current.remove(this);
    stage.remove(this);
    if (sendEvent) {
      sentEvent2Stage(constants.eventOnDestroy, this);
    }
  }

  @override
  bool canIGo(num lox, num loy) {
    if (lox == null || loy == null) {
      return false;
    }
    return chessPad.inRange(lox, loy) &&
        !(chessPad[lox][loy] as Block).hasBrick() &&
        (chessPad[lox][loy] as Block).others
                .where((item) => item is Bomb).length == 0;
  }

  @override
  onEvent(event, data) {
    if (event == constants.eventDamage) {
      print("$name get damaged: $data}");
      hp -= data;
    }
    if (event == constants.eventAnimEnd) {
      destroy();
    }
    if (event == constants.eventOnDestroy) {
      if (data is Bomb && data.owner == this) {
        _myBobes.remove(data);
      }
    }
  }

  void _deployBomb() {
    if (_myBobes.length >= _bombCount) {
      print("_deployBomb reach  limit: ${_bombCount}");
      return;
    }
    //print("_deployBomb");
    Bomb b = CountDownBomb(
        "bomb", ctx, stage, this, _power, 2500, current.x, current.y);
    audio.play("click");
    _myBobes.add(b);
    stage.add(b);
  }


  var lastkey;
  @override
  onKeyDown(keyCode) {
    switch (keyCode) {
      case constants.keyLeft:
        if(lastkey != keyCode ||util.isVector2Zero(v)) {
          animator.indexs = [4,5,6, 7];
          v = Vector2(-1.0, 0.0);
          lastkey = keyCode;
        }

        break;
      case constants.keyUp:
        if(lastkey != keyCode||util.isVector2Zero(v)) {
          animator.indexs = [12,13, 14,15];
          v = Vector2(0.0, -1.0);
          lastkey = keyCode;
        }

        break;
      case constants.keyRight:
        if(lastkey != keyCode||util.isVector2Zero(v)) {
          animator.indexs = [8,9,10, 11];
          v = Vector2(1.0, 0.0);
          lastkey = keyCode;
        }

        break;
      case constants.keyDown:
        if(lastkey != keyCode||util.isVector2Zero(v)) {
          animator.indexs = [0,1,2, 3];
          v = Vector2(0.0, 1.0);
          lastkey = keyCode;
        }

        break;
      case constants.keyA:
        _deployBomb();
        break;
      case constants.keyB:
      default:
        break;
    }
  }

  @override
  onKeyUp(keyCode) {
    switch (keyCode) {
      case constants.keyLeft:
        animator.indexs = [4];
        v = Vector2(0.0, 0.0);
        break;
      case constants.keyUp:
        animator.indexs = [12];
        v = Vector2(0.0, 0.0);
        break;
      case constants.keyRight:
        animator.indexs = [8];
        v = Vector2(0.0, 0.0);
        break;
      case constants.keyDown:
        animator.indexs = [0];
        v = Vector2(0.0, 0.0);
        break;
      case constants.keyA:
      case constants.keyB:
      default:
        break;
    }
  }
}

class HeroBuff implements PropertySetter {
  static HeroBuff instance;
  Hero h;
  num _speed = 3.0;
  int _power = 2;
  int _bombCount = 1;

  HeroBuff._init();
  factory HeroBuff(){
    if(instance == null) {
      instance = HeroBuff._init();
    }
    return instance;
  }

  _notice() {
    if (h != null) {
      h._power = _power;
      h.speed = _speed;
      h._bombCount = _bombCount;
    }
  }

  void reset() {
    h = null;
    _speed = 3.0;
    _power = 2;
    _bombCount = 1;
  }

  void subscribe(Hero h) {
    this.h = h;
    _notice();
  }

  @override
  set bombCount(v) {
    if (_bombCount < 10) {
      _bombCount += v;
      _notice();
    }
  }

  @override
  set bombType(v) {
    _notice();
  }

  @override
  set power(v) {
    //print('buff ${h.name}\' power to $v');
    if (_power < 10) {
      _power += v;
      _notice();
    }
  }

  @override
  set speed(v) {
    //print('buff ${h.name}\' speed to $v');
    if (_speed < 10) {
      _speed += v;
      _notice();
    }
  }
}
