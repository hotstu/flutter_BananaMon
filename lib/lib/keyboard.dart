import '../char/mixin/keyboardWatcher.dart';

abstract class Keyboard {
  bool isPressed(int keyCode);
  addListener(KeyBoardWatcher watcher);
  removeListener(KeyBoardWatcher watcher);
  pause();
  stop();
  start();
}