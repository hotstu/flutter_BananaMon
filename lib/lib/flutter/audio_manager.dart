import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';
import '../audio_manager.dart' as base;

class AudioManager implements base.AudioManager {
  static AudioManager instance;
  final AudioCache audioCache;
  static const mapping = {
    "bomb": "bomb.ogg",
    "click": "click.ogg",
    "powerup": "powerup.ogg",
    "opening": "01_Title Screen.mp3",
    "starting": "02_Stage Start.mp3",
    "playing": "03_Stage Theme.mp3",
    "Life Lost": "08_Life Lost.mp3",
    "Stage Complete": "05_Stage Complete.mp3"
  };

  AudioManager._internal() :audioCache = AudioCache();

  factory AudioManager() {
    if (instance == null) {
      instance = AudioManager._internal();
    }
    return instance;
  }

  Stream<int> init() {
    StreamController<int> controller;

    controller = StreamController(onListen: () async {
      //await audioCache.load(mapping["bomb"]);
      controller.close();
    });
    return controller.stream;
  }

  @override
  Future<SoundPlay> play(String name, [loop = false]) async {
    //SoundPlay play = SoundPlay(await audioCache.play(mapping[name]));
    SoundPlay play = SoundPlay(null);
    play.loop = loop;
    play.start();
    return play;
  }
}

class SoundPlay implements base.SoundPlay {
  bool _playing = false;
  bool _looping = false;

  AudioPlayer audioPlayer;

  SoundPlay(this.audioPlayer);

  set loop(bool v) {
    _looping = v;
    audioPlayer?.setReleaseMode(v ? ReleaseMode.LOOP : ReleaseMode.RELEASE);
  }

  @override
  bool get loop => _looping;

  @override
  bool get playing => _playing;

  @override
  void start() {
    _playing = true;
    audioPlayer?.resume();
  }

  @override
  void stop() {
    _playing = false;
    audioPlayer?.pause();
  }

  @override
  void toggle() {
    _playing ? stop() : start();
    _playing = !_playing;
  }

  @override
  void release() {
    _playing = false;
    audioPlayer?.release();
  }
}
