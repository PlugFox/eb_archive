import 'dart:async';

import 'exception.dart';
import 'transition.dart';

/// TODO: реализовать возможность распределения по изолятам (при этом оставить поддержку веба)
/// Менеджеры ответственные за общение между изолятами с основным потоком

///
class EventBus {
  static final StreamController<Message> _queue =
      StreamController<Message>.broadcast();

  /// Получить объект синглтона шины данных
  factory EventBus() => _instance;
  static const EventBus _instance = EventBus._internalSingleton();
  const EventBus._internalSingleton();

  /// Поток событий
  Stream<Message> get messages =>
    _queue.stream.handleError((Object _) => null);

  /// Поток ошибок
  Stream<EventBusException> get errors => _queue.stream.transform<EventBusException>(
      StreamTransformer<Message, EventBusException>.fromHandlers(
        handleData: (Message _, EventSink<EventBusException> __) => null,
        handleError: (Object error, StackTrace stackTrace, EventSink<EventBusException> sink) =>
            sink.add(EventBusException(error: error, stackTrace: stackTrace)),        
      ));

  /// Добавить событие
  void emit(Message nextMsg) {
    try {
      _queue.add(nextMsg);
    } on dynamic catch (error, stackTrace) {
      _queue.addError(error, stackTrace);
      assert(() {
        throw EventBusException(error: error, stackTrace: stackTrace);
      }());
    }
  }

  /// Закрыть шину данных
  /// ВНИМАНИЕ, ЭТО НЕОБРАТИМО
  Future<void> kill() => _queue.close();

}