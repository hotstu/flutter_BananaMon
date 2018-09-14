import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart';

import '../../char/mixin/keyboardWatcher.dart';
import '../keyboard.dart' as base;
import '../constants.dart' as constants;
import 'util.dart' as util;

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
    init();
  }

  init() {
    if (GestureBinding?.instance?.pointerRouter == null) {
      return;
    }
    if (callback != null) {
      return;
    }
    final recognizer = TapGestureRecognizer()
      ..onTapDown = _onTapDown
      ..onTapUp = _onTapUp;
    callback = (PointerEvent e) {
      if (e is PointerDownEvent) {
        recognizer.addPointer(e);
      }
    };
    GestureBinding.instance.pointerRouter.addGlobalRoute(callback);
  }

  _onTapDown(TapDownDetails ev) {
    print("onTapDown${ev.globalPosition}");
    _keyDownControler.add(ev);
  }

  _onTapUp(TapUpDetails ev) {
    print("onTapDown${ev.globalPosition}");
    _keyUpControler.add(ev);
  }


  @override
  void start() {
    init();
    if (keydownSub != null) {
      if (keydownSub.isPaused) {
        keydownSub.resume();
      }
      return;
    }
    keydownSub = _keyDownControler.stream.listen((event) {
      final keyCode = 0x58;
      _keys.putIfAbsent(keyCode, () => 1);

      List.from(listeners).forEach((watcher) {
        watcher.onKeyDown(_mappingRev(keyCode));
      });
    });

    keyupSub = _keyUpControler.stream.listen((event) {
      final keyCode = 0x58;
      _keys.remove(keyCode);
       List.from(listeners).forEach((watcher) {
        watcher.onKeyUp(_mappingRev(keyCode));
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

  int _mapping(int gen) {
    switch (gen) {
      case constants.keyLeft:
        return 0x25;
      case constants.keyUp:
        return 0x26;
      case constants.keyRight:
        return 0x27;
      case constants.keyDown:
        return 0x28;
      case constants.keyA:
        return 0x58;
      case constants.keyB:
        return 0x5a;
    }
    return 0;
  }

  int _mappingRev(int gen) {
    switch (gen) {
      case 0x25:
        return constants.keyLeft;
      case 0x26:
        return constants.keyUp;
      case 0x27:
        return constants.keyRight;
      case 0x28:
        return constants.keyDown;
      case 0x58:
        return constants.keyA;
      case 0x5a:
        return constants.keyB;
    }
    return 0;
  }

  bool isPressed(int keyCode) => _keys.containsKey(_mapping(keyCode));

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
