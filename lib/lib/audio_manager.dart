
abstract class AudioManager {
  static const String lifLost = "Life Lost";
  static const String bomb = "bomb";
  static const String click = "click";
  static const String powerup = "powerup";
  static const String opening = "opening";
  static const String starting = "starting";
  static const String playing = "playing";
  static const String stageComplete = "Stage Complete";

  init();

  SoundPlay play(String name, [loop = false]);
}

abstract class SoundPlay  {


  set loop(bool v);

  bool get loop;
  bool get playing;

  void start();

  void stop();

  void toggle() ;

}