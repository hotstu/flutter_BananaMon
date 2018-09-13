import 'package:vector_math/vector_math.dart';

import '../lib/audio_manager.dart';
import '../lib/sprite.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import 'explosion.dart';
import 'mixin/property.dart';
import '../lib/constants.dart' as constants;
import '../lib/injection.dart' as inject;

class Bomb extends BaseChar {
  List<Sprite> sps;
  Animator animator;
  final int power;
  BaseChar owner;
  int state = constants.stateNormal;
  AudioManager audio;

  Bomb(String name, ctx, Stage stage, this.owner, this.power,
      [int x = 0, int y = 0])
      : assert(name != null),
        audio = inject.injectAudio(),
        super(name, ctx, stage, x, y) {
    v = Vector2(1.0, 0.0);
    sps = ctx.obtainSoureDesc(type);
    animator = Animator([0, 1], 300);
  }

  @override
  void tick() {
    animator.tick();
  }

  void _explosion() {
    // add explosion around
    Explosion exp = Explosion.fromBomb(this);
    if (exp != null) {
      audio.play("bomb");
      stage.add(exp);
    }
  }

  @override
  void onEvent(event, data) {
    if (event == constants.eventDamage) {
      state = constants.stateDestroying;
    }
  }

  @override
  void destroy([bool sendEvent = true]) {
    state = constants.stateDestroyed;
    _explosion();
    if(sendEvent) {
      sentEvent(owner, constants.eventOnDestroy, this);
    }
    current.remove(this);
    stage.remove(this);
  }

  @override
  Property get property => this;

  @override
  double get iq => 0.0;

  @override
  double get speed => 5.0;

  @override
  String get type => constants.sourceIdBomb1;

  @override
  Sprite get sprite => sps[animator.index];
}

class CountDownBomb extends Bomb {
  final int llt;
  int deployedTime;

  CountDownBomb(
      String name, ctx, Stage stage, BaseChar owner, int power, this.llt,
      [int x, int y])
      : super(name, ctx, stage, owner, power, x, y);

  @override
  void tick() {
    if (state == constants.stateDestroyed) {
      return;
    }
    if (state == constants.stateNormal) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (deployedTime == null) {
        deployedTime = now;
      }
      if (now - deployedTime >= llt) {
        state = constants.stateDestroying;
      }
      super.tick();
      return;
    }
    if (state == constants.stateDestroying) {
      destroy();
    }
  }
}
