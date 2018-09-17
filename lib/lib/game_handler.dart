import '../scene/scene.dart';

abstract class GameHandler {
  void add(String name, Scene scene );
  void start(String name, [attr]);
  void pause();
  void resume();
  void destroy();
}