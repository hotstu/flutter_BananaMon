import 'audio_manager.dart' as base;
import 'flutter/audio_manager.dart' as impl;
import 'keyboard.dart' as base1;
import 'flutter/keyboard.dart' as impl1;
import 'level_provider.dart' as base2;
import 'flutter/level_provider.dart' as impl2;
import 'flutter/resourcProvider.dart';
//提供所有单例的入口

base.AudioManager injectAudio() {
  return impl.AudioManager();
}

ResourceProvider injectResourceProvider() {
  return ResourceProvider();
}

base1.Keyboard injectKeyboard() {
  return impl1.Keyboard.single();
  //return null;
}

base2.LevelProvider injectLevelProvider() {
  return impl2.LevelProvider.single();
}

