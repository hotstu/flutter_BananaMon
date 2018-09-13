import '../../lib/canvas_wrapper.dart';
import 'property.dart';

abstract class ViewItem {
  Property get property;
  void draw() {
    //print("${property.name} draw");
    CanvasWrapper ctx = property.ctx;
    //ctx.rclearRect(property.position.x.toInt(), property.position.y.toInt());
    ctx.rdrawImage(property.sprite, property.rect);
  }
}