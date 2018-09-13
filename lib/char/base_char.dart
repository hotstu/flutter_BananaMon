import 'package:vector_math/vector_math.dart';

import '../lib/chess_pad.dart';
import '../lib/canvas_wrapper.dart';

import '../lib/rect.dart';
import '../stage/stage.dart';
import 'mixin/property.dart';
import 'mixin/viewItem.dart';
import '../lib/constants.dart' as constants;


abstract class BaseChar extends Object with Property, ViewItem {
  final String name;
  final CanvasWrapper ctx;
  final Stage stage;
  Rect<num> rect;
  Block current;

  /**
   * v 的大小不应大于一个单元格的宽度，否则可能会穿墙
   */
  Vector2 v;

  BaseChar(this.name, this.ctx, this.stage, num x, num y) {
    current = stage.chessPad[x][y];
    current.add(this);
    rect = current.rect.clone();
  }

  void tick();

  ChessPad get chessPad => stage.chessPad;

  void _ensureBLock() {
    var center = this.rect.center;
    if (current.rect.containsPoint(center)) {
      return;
    } else {
      current.remove(this);
      var adjBlocks = current.adjBlocks;
      for (var i = 0; i < adjBlocks.length; ++i) {
        Block o = adjBlocks[i];
        if (o != null && o.rect.containsPoint(center)) {
          current = o;
          current.add(this);
          return;
        }
      }
      current = null;
      destroy();
    }
  }

  sentEvent (BaseChar char, String event, data) async{
    if (char != null) {
      await char.onEvent(event, data);
    }
  }
  sentEvent2Stage (event, data) async{
      await stage.onEvent(event, data);
  }

  void onEvent(event, data) {
    //print("onEvnet${event}=>${data}");
  }

  void offset(Vector2 diff) {
    rect.offset(diff);
    _ensureBLock();
  }

  void destroy([bool sendEvent = true]) {
    //print("$name destoryed");
  }

  void moveTo(Vector2 position) {
    rect.left = position.x;
    rect.top = position.y;
    _ensureBLock();
  }

  @override
  Property get property => this;
}

class Animator {
  List<int> _indexs;
  int _peroid;
  int _index = 0;
  int lastTick = 0;
  int count = 0;
  bool loop;

  BaseChar owner;

  Animator(this._indexs, this._peroid, [this.loop = true, BaseChar this.owner]);

  void set indexs(List<int> v) {
    //print("set indexs $v");
    _indexs = v;
    _index = 0;
  }

  void set peroid(int v) {
   // print("set perioid $v");

    _peroid = v;
    _index = 0;
  }

  tick() {
    if (lastTick == 0) {
      lastTick = DateTime.now().millisecondsSinceEpoch;
      return;
    }
    int current = DateTime.now().millisecondsSinceEpoch;
    int diff = current - lastTick;
    lastTick = current;
    if ((count + diff) >= _peroid) {
      //print("Animator${_indexs.length} ${_index} ${count} ${ _peroid}");
      count = (count + diff) % _peroid;
      if (loop) {
        _index = (_index + 1) % _indexs.length;
      } else {
        //print("Anim ${_index} ${_indexs.length} ${owner}");
        if (_index + 1 >= _indexs.length && owner != null) {
          owner.sentEvent(owner, constants.eventAnimEnd, this);
        } else {
          _index += 1;
        }
      }
    } else {
      count += diff;
    }
  }

  int get index => _indexs[_index];
}
