import '../lib/chess_pad.dart';
import '../lib/canvas_wrapper.dart';
import '../lib/sprite.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import 'bomb.dart';
import 'brick.dart';
import 'mixin/property.dart';
import '../lib/constants.dart' as constants;
import 'dart:math' as math;

class Explosion extends BaseChar {
  List<Sprite> sps;
  Animator animator;
  int power;
  BaseChar owner;
  List<int> growDirections;
  bool firstTick = true;
  bool destoryed = false;

  Explosion.fromBomb(Bomb b)
      : super('explosion', b.ctx, b.stage, b.current.x, b.current.y){
    sps = ctx.obtainSoureDesc(type);
    animator = Animator(
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 30,
        false,
        this);
    owner = b;
    power = b.power;
    growDirections = [0,1,2,3];
  }

  Explosion._internal(String name, CanvasWrapper ctx, Stage stage, int x, int y)
      : super(name, ctx, stage,  x, y) {
  }

  factory Explosion.fromExplosion(Explosion exp, int direction){
    if(exp.power <= 0) {
      return null;
    }
    if(exp.current.hasBrick()) {
      return null;
    }
    var b = exp.current;
    Block dest = b.adjBlocks[direction];
    if(dest == null) {
      return null;
    }
    if(!dest.bricks.every((item) {
      return (item is WeakBrick);
    })) {
      return null;
    }
    Explosion e = Explosion._internal("explosion", exp.ctx, exp.stage, dest.x, dest.y);
    e.sps = e.ctx.obtainSoureDesc(e.type);
    e.animator = Animator(
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 30,
        false, e);
    e.owner = exp;
    e.power = exp.power - 1;
    e.growDirections = [direction];
    return e;
  }

  @override
  void tick() {
    if(destoryed) {
      return;
    }
    if(firstTick) {
      firstTick = false;
      _expandIfPossible();
    }
    _explosion();
    animator.tick();
  }

  void  _expandIfPossible() {
    //TODO 衰减、障碍 、延迟
    if(power <= 1) {
      return;
    }
    for (var i = 0; i < growDirections.length; ++i) {
      var direction = growDirections[i];
      var explosion = Explosion.fromExplosion(this, direction);
      if(explosion != null) {
        stage.add(explosion);
      }
    }
  }

  void _explosion() {
    current.bricks.forEach((brick){
      sentEvent(brick, constants.eventDamage, power);
    });
    current.others.forEach((other){
      sentEvent(other, constants.eventDamage, power);
    });

  }



  @override
  void onEvent(event, data) {
    if (event == constants.eventAnimEnd) {
      destroy();
    }
  }

  @override
  void destroy([bool sendEvent = false]) {
    destoryed = true;
    //print("${name} onDestory");
    //sentEvent(owner, constants.eventOnDestroy, this);
    current.remove(this);
    stage.remove(this);
    current = null;
  }

  @override
  Property get property => this;

  @override
  double get iq => 0.0;

  @override
  double get speed => 10.0;

  @override
  String get type => constants.sourceIdExplosion1;

  @override
  Sprite get sprite => sps[animator.index];
}



