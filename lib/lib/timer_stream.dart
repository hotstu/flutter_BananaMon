import 'dart:async';

/**
 * one shot anim
 */
class TimerStream {
  StreamController<int> _controller;
  Timer _timer;
  final Duration period;
  int limit;
  TimerStream(this.period,[this.limit]) {
    _controller = StreamController(onListen: _onListen, onCancel: _onCancel);
  }

  Stream<int> get stream => _controller.stream;

  _onListen() {
    _timer = Timer.periodic(period, _tick);
  }

  _onCancel() {
    _timer.cancel();
    _timer = null;
    if(!_controller.isClosed) {
      _controller.close();
    }
  }

  _tick(Timer t) {
    _controller.add(t.tick);
    if(limit != null && t.tick +1>= limit) {
      _controller.close();
    }
  }

}

Future delay(Duration duration) async {
  return Future.delayed(duration);
}