import 'dart:async';

import 'exception.dart';
import 'filters.dart';
import 'transition.dart';


///
class EventBus {
  final _EventBusState _state;

  /// Последнее событие
  Event get event => _state.lastEvent;

  /// Поток событий
  Stream<Event> events;
  
  /// Поток ошибок
  Stream<EventBusException> errors;

  /// Добавить событие
  void emit(Event nextEvent) =>
    _state.add(nextEvent);

  /// Закрыть шину данных
  Future<void> close() =>
    _state.close();

  /// TODO: Добавить возможность подписки на темы

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  Stream<Event> whereEvents<EventType extends Event>() =>
    events.transform(WhereTypeTransformer<Event, EventType>());

  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevEvent, NextEvent>> whereTransition<PrevEvent extends Event, NextEvent extends Event>({bool onlyCompletely = false}) =>
    events.transform(WhereTransitionTransformer<Event, PrevEvent, NextEvent>(onlyCompletely: onlyCompletely));
  
  /// Получить объект синглтона шины данных
  factory EventBus() => _instance;
  static final EventBus _instance = EventBus._internalSingleton();
  EventBus._internalSingleton()
    : _state = _EventBusState() {
    events = _state.events;
    errors = _state.errors;
  }

}


class _EventBusState implements Sink<Event> {
  final StreamController<Event> _controller = StreamController<Event>.broadcast();

  /// Последнее событие
  Event lastEvent;

  /// Поток событий
  Stream<Event> events;
  
  /// Поток ошибок
  Stream<EventBusException> errors;

  _EventBusState() {
    /// Инициализация шины данных
    events = _controller.stream.handleError((Object _) => null);
    errors = _controller.stream
      .transform<EventBusException>(StreamTransformer<Event, EventBusException>.fromHandlers(
        handleData: (Event nextEvent, EventSink<EventBusException> _) => lastEvent = nextEvent,
        handleError: (Object error, StackTrace stackTrace, EventSink<EventBusException> sink) =>
          sink.add(EventBusException(error: error, stackTrace: stackTrace)),
      ));
  }

  @override
  void add(Event nextEvent) {
    try {
      _controller.add(nextEvent);
    } on dynamic catch (error, stackTrace) {
      _onError(error, stackTrace);
    }
  }

  @override
  Future<void> close() =>
    _controller.close();
  
  void _onError(Object error, StackTrace stackTrace) {
    _controller.addError(error, stackTrace);
    assert(() {
      throw EventBusException(error: error, stackTrace: stackTrace);
    }());
  }
}