import 'dart:async';

import '../lib/canvas_wrapper.dart';

import 'package:vector_math/vector_math.dart';

import '../lib/sprite.dart';
import '../stage/stage.dart';
import 'base_char.dart';
import '../lib/constants.dart' as constants;

abstract class PropertySetter {
  set speed(v);

  set power(v);

  set bombCount(v);

  set bombType(v);
}

abstract class Treasure extends BaseChar {
  List<Sprite> sps;
  final Vector2 _zero2 = Vector2.zero();

  Treasure(String name, CanvasWrapper ctx, Stage stage, [num x = 0, num y = 0])
      : super(name, ctx, stage, x, y) {
    sps = ctx.obtainSoureDesc(this.type);
  }

  @override
  void destroy([bool sendEvent = true]) {
    current.remove(this);
    stage.remove(this);
  }

  buff(PropertySetter setter)  {
    Future.delayed(Duration.zero, () => _buff(setter));
  }

  _buff(PropertySetter setter);

  @override
  double get iq => 0.0;

  @override
  double get speed => 0.0;

  @override
  void tick() {}


  @override
  Vector2 get v => _zero2;

  @override
  String get type => constants.sourceIdTreasure1;

  @override
  Sprite get sprite => sps[0];
}

class TreasureSpeedUp extends Treasure {
  TreasureSpeedUp(String name, CanvasWrapper ctx, Stage stage, [int x = 0, int y = 0])
      : super(name, ctx, stage,x, y);

  @override
  _buff(PropertySetter setter) {
    setter.speed = 1;
    destroy();
  }

  @override
  Sprite get sprite => sps[0];
}

class TreasurePowerUp extends Treasure {
  TreasurePowerUp(String name, CanvasWrapper ctx, Stage stage, [int x = 0, int y = 0])
      : super(name, ctx, stage,x, y);

  @override
  _buff(PropertySetter setter) {
    setter.power = 1;
    destroy();
  }

  @override
  Sprite get sprite => sps[1];
}

class TreasureBombCountUp extends Treasure {
  TreasureBombCountUp(String name, CanvasWrapper ctx, Stage stage, [int x = 0, int y = 0])
      : super(name, ctx, stage,x, y);

  @override
  _buff(PropertySetter setter) {
    setter.bombCount = 1;
    destroy();
  }

  @override
  Sprite get sprite => sps[2];
}

class TreasureBombType extends Treasure {
  String bombtype;

  TreasureBombType(String name, CanvasWrapper ctx, Stage stage, this.bombtype,  [int x = 0, int y = 0])
      : super(name, ctx, stage, x, y);

  @override
  _buff(PropertySetter setter) {
    setter.bombType = bombtype;
    destroy();
  }

  @override
  Sprite get sprite => sps[3];
}

class TreasureGate extends Treasure {

  bool applyed = false;
  TreasureGate(String name, CanvasWrapper ctx, Stage stage,   [int x = 0, int y = 0])
      : super(name, ctx, stage, x, y);

  @override
  _buff(PropertySetter setter) {
    if(applyed) {
      return;
    }
    if(stage.monsterList?.length == 0) {
      applyed = true;
      sentEvent2Stage(constants.eventLevelComplte, 0);
    }
    //destroy();
  }


  @override
  String get type => constants.sourceIdGate1;

  @override
  Sprite get sprite => sps[0];
}
