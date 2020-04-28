import 'bus.dart';
import 'exception.dart';
import 'filters.dart';
import 'transition.dart';

export 'exception.dart';
export 'transition.dart';

/// Функция принимающая Event и возвращающая void
typedef EventCallback = void Function(Event);
/// Функция принимающая EventBusError и возвращающая void
typedef EventBusExceptionCallback = void Function(EventBusException);

/// Миксин для отправителя событий в шину данных
mixin Publisher {
  static final EventBus _eventBus = EventBus();

  /// Добавить событие
  void emit(Event event) => _eventBus.emit(event);
}

/// Миксин для приемника событий из шины данных
mixin Subscriber {
  static final EventBus _eventBus = EventBus();

  /// Поток событий
  final Stream<Event> events = _eventBus.events;

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  Stream<Event> whereEvents<EventType extends Event>({String topic = '*'}) =>
      events.transform(WhereEventTypeTransformer<EventType>(topic: topic));

  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevEvent, NextEvent>>
      whereTransition<PrevEvent extends Event, NextEvent extends Event>(
              {String topic = '*', bool onlyCompletely = false}) =>
          events.transform(
              WhereEventTransitionTransformer<PrevEvent, NextEvent>(
                  topic: topic,
                  onlyCompletely: onlyCompletely));

  /// Коллбэк на событие
  /// Укажите дженерик для фильтрации
  void onEvent<EventType extends Event>(EventCallback callback, {String topic = '*'}) =>
      whereEvents<EventType>(topic: topic).forEach(callback);
}

/// Миксин для приемника ошибок из шины данных
mixin ExceptionSubscriber {
  /// Поток ошибок
  final Stream<EventBusException> errors = EventBus().errors;

  /// Коллбэк на ошибку
  void onError(EventBusExceptionCallback callback) =>
      errors.forEach(callback);
}
