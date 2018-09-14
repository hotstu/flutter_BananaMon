import 'dart:async';
import 'dart:collection';

import '../../char/mixin/keyboardWatcher.dart';
import '../keyboard.dart' as base;


/**
 * keyboard is a singleton
 */
class Keyboard extends base.Keyboard {
  static Keyboard _instance;

  HashMap<int, num> _keys = new HashMap<int, num>();
  List<KeyBoardWatcher> listeners;
  StreamSubscription keydownSub;
  StreamSubscription keyupSub;
  StreamController _keyDownControler;
  StreamController _keyUpControler;
  var callback;

  Keyboard._internal() {
    listeners = [];
    _keyDownControler = StreamController();
    _keyUpControler = StreamController();
  }

  @deprecated
  init() {}

  @override
  void start() {
    if (keydownSub != null) {
      if (keydownSub.isPaused) {
        keydownSub.resume();
      }
      return;
    }
    keydownSub = _keyDownControler.stream.listen((keyCode) {
      _keys.putIfAbsent(keyCode, () => 1);

      List.from(listeners).forEach((watcher) {
        watcher.onKeyDown(keyCode);
      });
    });

    keyupSub = _keyUpControler.stream.listen((keyCode) {
      _keys.remove(keyCode);
       List.from(listeners).forEach((watcher) {
        watcher.onKeyUp(keyCode);
      });
    });
  }

  @override
  void pause() {
    if (keydownSub == null || keydownSub.isPaused) {
      return;
    }
    keydownSub.pause();
    keyupSub.pause();
  }

  @override
  void stop() {
    keydownSub.cancel();
    keyupSub.cancel();
    keydownSub = null;
    keyupSub = null;
  }

  factory Keyboard.single() {
    if (_instance == null) {
      _instance = Keyboard._internal();
    }
    return _instance;
  }

  @override
  String toString() => _keys.toString();



  bool isPressed(int keyCode) => _keys.containsKey(keyCode);

  sendKeyEvent(int keyCode, [isKeyUp = false]) {
    if(isKeyUp) {
      _keyUpControler.add(keyCode);
    }
    else {
      _keyDownControler.add(keyCode);
    }
  }

  @override
  addListener(KeyBoardWatcher watcher) {
    if (listeners.indexOf(watcher) == -1) {
      listeners.add(watcher);
    }
  }

  @override
  removeListener(KeyBoardWatcher watcher) async {
    listeners.remove(watcher);
  }
}
