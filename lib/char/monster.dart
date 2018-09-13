import 'package:vector_math/vector_math.dart';

import '../lib/chess_pad.dart';
import '../lib/sprite.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import 'bomb.dart';
import 'hero.dart';
import 'mixin/brain.dart';
import 'mixin/leg.dart';
import 'mixin/property.dart';
import '../lib/constants.dart' as constants;

class Monster extends BaseChar with Brain, Leg {
  List<Sprite> sps;
  List<Sprite> sps2;
  num hp = 30;
  num power = 1;
  num skillDistanceSqure = 20 * 20;

  int state = constants.stateNormal;
  Animator anim = null;

  Monster(String name, ctx, Stage stage, [int x = 0, int y = 0])
      : assert(name != null),
        super(name, ctx, stage, x, y) {
    v = Vector2(1.0, 0.0).normalized();
    sps = ctx.obtainSoureDesc(type);
    sps2 = ctx.obtainSoureDesc(constants.sourceIdDestory2);
  }

  @override
  void tick() {
    if (state == constants.stateDestroyed) {
      return;
    }
    think();
    move();
  }

  @override
  void onEvent(event, data) {
    if (event == constants.eventDamage) {
      hp -= data;
    }
    if (event == constants.eventAnimEnd) {
      destroy();
    }
  }

  _startDestory() {
    state = constants.stateDestroying;
    v = Vector2.zero();
    //sps = ctx.obtainSoureDesc(type);
    anim = Animator([1, 2, 3, 4, 5], 100, false, this);
  }

  @override
  void destroy([bool sendEvent = true]) {
    state = constants.stateDestroyed;
    current.remove(this);
    stage.remove(this);
    if(sendEvent) {
      sentEvent2Stage(constants.eventOnDestroy, this);
    }

  }

  @override
  void think() {
    if (state == constants.stateDestroying) {
      anim.tick();
      return;
    }
    if (state == constants.stateNormal) {
      if (hp <= 0) {
        _startDestory();
        return;
      }
      //TODO
      current.others.where((cha) => cha is Hero).forEach(_damageFunc);
      current.adjBlocks
          .where((block) => block != null)
          //.map((block) => block.others)
          .expand((block) => block.others)
          .where((cha) => cha is Hero)
          .forEach(_damageFunc);
      //rect.center.squaredDistanceTo(other)
      super.think();
      return;
    }
  }

  _damageFunc(BaseChar hero) {
    if (rect.center.squaredDistanceTo(hero.rect.center) <= skillDistanceSqure) {
      sentEvent(hero, constants.eventDamage, power);
    }
  }

  @override
  Property get property => this;

  @override
  BaseChar get delegate => this;

  @override
  double get iq => 100.0;

  @override
  double get speed => 2.0;

  @override
  String get type => constants.sourceIdMonster1;

  bool get alive => hp > 0;

  @override
  Sprite get sprite {
    if (state == constants.stateNormal) {
      return sps[hp == 30 ? 0 : 1];
    } else {
      return sps2[anim.index];
    }
  }

  @override
  bool canIGo(num lox, num loy) {
    if (lox == null || loy == null) {
      return false;
    }
    return chessPad.inRange(lox, loy) &&
        !(chessPad[lox][loy] as Block).hasBrick()
      && (chessPad[lox][loy] as Block).others.where((item) => item is Bomb).length == 0
    ;
  }
}
