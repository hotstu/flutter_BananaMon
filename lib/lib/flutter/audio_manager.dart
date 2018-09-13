import 'dart:async';
import '../audio_manager.dart' as base;

//TODO make implematation
class AudioManager implements base.AudioManager {
  static AudioManager instance;


  AudioManager._internal() {

  }

  factory AudioManager() {
    if (instance == null) {
      instance = AudioManager._internal();
    }
    return instance;
  }

  Stream<int> init() {
    StreamController<int> controller;
    controller = StreamController(onListen: () async {
      controller.close();
    });
    return controller.stream;
  }

  @override
  SoundPlay play(String name, [loop = false]) {
    SoundPlay play = SoundPlay();
    play.loop = loop;
    play.start();
    return play;
  }
}

class SoundPlay implements base.SoundPlay {
  bool _playing = false;

  SoundPlay();

  set loop(bool v) {
  }

  @override
  bool get loop => false;

  @override
  bool get playing => _playing;

  @override
  void start() {
    _playing = true;
  }

  @override
  void stop() {
    _playing = false;
  }

  @override
  void toggle() {
    _playing ? stop() : start();
    _playing = !_playing;
  }
}
