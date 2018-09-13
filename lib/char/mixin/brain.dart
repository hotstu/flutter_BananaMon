
import '../base_char.dart';
import '../../lib/util.dart' as util;
import '../../lib/seed.dart' as rand;

abstract class Brain {
  BaseChar get delegate;

  void think() {
    //TODO 更加智能
    //print("${property.name} thinking");
    if(util.isVector2Zero(delegate.v)) {
      delegate.v = rand.nextV();
    }
  }
}
