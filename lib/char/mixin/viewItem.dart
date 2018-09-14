import '../../lib/canvas_wrapper.dart';
import 'property.dart';

abstract class ViewItem {
  Property get property;
  void draw(CanvasWrapper ctx) {
    //print("${property.name} draw");
    //ctx.rclearRect(property.position.x.toInt(), property.position.y.toInt());
    ctx.rdrawImage(property.sprite, property.rect);
  }
}