import 'bus.dart';
import 'exception.dart';
import 'transition.dart';

export 'exception.dart';
export 'transition.dart';

/// Функция принимающая Event и возвращающая void
typedef EventCallback = void Function(Event);

/// Функция принимающая EventBusError и возвращающая void
typedef EventBusExceptionCallback = void Function(EventBusException);

/// Миксин для отправителя событий в шину данных
mixin Publisher {
  final EventBus _eventBus = EventBus();

  /// Добавить событие
  void emit(Event event) => _eventBus.emit(event);
}

/// Миксин для приемника событий из шины данных
mixin Subscriber {
  final EventBus _eventBus = EventBus();

  /// Последнее событие
  Event get event => _eventBus.event;

  /// Поток событий
  Stream<Event> get events => _eventBus.events;

  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevEvent, NextEvent>>
      whereTransition<PrevEvent extends Event, NextEvent extends Event>(
              {bool onlyCompletely = false}) =>
          _eventBus.whereTransition<PrevEvent, NextEvent>(
              onlyCompletely: onlyCompletely);

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  Stream<Event> whereEvents<EventType extends Event>() =>
      _eventBus.whereEvents<EventType>();

  /// Коллбэк на событие
  /// Укажите дженерик для фильтрации
  void onEvent<EventType extends Event>(EventCallback callback) =>
      _eventBus.whereEvents<EventType>().forEach(callback);
}

/// Миксин для приемника ошибок из шины данных
mixin ExceptionSubscriber {
  final EventBus _eventBus = EventBus();

  /// Поток ошибок
  Stream<EventBusException> get errors => _eventBus.errors;

  /// Коллбэк на ошибку
  void onError(EventBusExceptionCallback callback) =>
      _eventBus.errors.forEach(callback);
}
