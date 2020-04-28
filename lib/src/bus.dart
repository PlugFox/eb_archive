import 'dart:async';

import 'exception.dart';
import 'transition.dart';

/// TODO: реализовать возможность распределения по изолятам (при этом оставить поддержку веба)
/// Менеджеры ответственные за общение между изолятами с основным потоком

///
class EventBus {
  static final StreamController<Event> _controller =
      StreamController<Event>.broadcast();

  /// Получить объект синглтона шины данных
  factory EventBus() => _instance;
  static const EventBus _instance = EventBus._internalSingleton();
  const EventBus._internalSingleton();

  /// Поток событий
  Stream<Event> get events =>
    _controller.stream.handleError((Object _) => null);

  /// Поток ошибок
  Stream<EventBusException> get errors => _controller.stream.transform<EventBusException>(
      StreamTransformer<Event, EventBusException>.fromHandlers(
        handleData: (Event _, EventSink<EventBusException> __) => null,
        handleError: (Object error, StackTrace stackTrace, EventSink<EventBusException> sink) =>
            sink.add(EventBusException(error: error, stackTrace: stackTrace)),        
      ));

  /// Добавить событие
  void emit(Event nextEvent) {
    try {
      _controller.add(nextEvent);
    } on dynamic catch (error, stackTrace) {
      _onError(error, stackTrace);
    }
  }

  /// Закрыть шину данных
  /// ВНИМАНИЕ, ЭТО НЕОБРАТИМО
  Future<void> kill() => _controller.close();

  void _onError(Object error, StackTrace stackTrace) {
    _controller.addError(error, stackTrace);
    assert(() {
      throw EventBusException(error: error, stackTrace: stackTrace);
    }());
  }
}