import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'currentindex_event.dart';

class CurrentindexBloc {
  int _currentIndex = 0;
  final _currentIndexStateController = StreamController<int>();
  StreamSink<int> get _inCounter => _currentIndexStateController.sink;
  Stream<int> get counter => _currentIndexStateController.stream;
  final _currentIndexEventController = StreamController<CurrentindexEvent>();
  Sink<CurrentindexEvent> get counterEventSink =>
      _currentIndexEventController.sink;

  CurrentindexBloc() {
    _currentIndexEventController.stream.listen(_mapEventToState);
  }
  void _mapEventToState(CurrentindexEvent event) {
    if (event is IncrementEvent)
      _currentIndex++;
    else
      _currentIndex--;

    _inCounter.add(_currentIndex);
  }

  void dispose() {
    _currentIndexEventController.close();
    _currentIndexStateController.close();
  }
}
