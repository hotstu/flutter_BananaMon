import '../lib/canvas_wrapper.dart';

import 'package:vector_math/vector_math.dart';

import '../lib/sprite.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import '../lib/constants.dart' as constants;

class Brick extends BaseChar {

  List<Sprite> sps;
  final Vector2 _zero2 = Vector2.zero();

  Brick(String name, CanvasWrapper ctx, Stage stage,[num x = 0, num y = 0])
      : super(name, ctx, stage, x, y) {
    sps = ctx.obtainSoureDesc(this.type);
  }


  @override
  double get iq => 0.0;

  @override
  double get speed => 0.0;

  @override
  void tick() {
  }

  @override
  Vector2 get v => _zero2;

  @override
  String get type => constants.sourceIdWall2;

  @override
  Sprite get sprite => sps[0];
}

class WeakBrick extends Brick {
  int hp = 1;
  int state = constants.stateNormal;
  Animator anim = null;
  List<Sprite> sps2;

  WeakBrick(String name, CanvasWrapper ctx, Stage stage,[num x = 0, num y = 0]) : super(name, ctx, stage,x, y ){
    sps2 = ctx.obtainSoureDesc(constants.sourceIdDestory2);
  }

  @override
  String get type => constants.sourceIdWall1;

  @override
  void onEvent(event, data) {
    if(event == constants.eventDamage) {
      hp -= data;
    }
    if (event == constants.eventAnimEnd) {
      destroy();
    }
  }

  @override
  void tick() {
    if (state == constants.stateDestroyed) {
      return;
    }
    if (state == constants.stateDestroying) {
      anim.tick();
      return;
    }
    if (state == constants.stateNormal) {
      if(hp <= 0) {
        _startDestory();
      }
    }

  }

  void _startDestory() {
    state = constants.stateDestroying;
    //sps = ctx.obtainSoureDesc(type);
    anim = Animator([1, 2, 3, 4, 5], 100, false, this);
  }

  @override
  void destroy([bool sendEvent = false]) {
    state = constants.stateDestroyed;
    current?.remove(this);
    stage?.remove(this);
  }

  @override
  Sprite get sprite {
    if (state == constants.stateDestroying) {
      return sps2[anim.index];
    } else {
      return sps[0];
    }
  }

}
