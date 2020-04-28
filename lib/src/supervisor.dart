import 'bus.dart';
import 'mixins.dart';

/// Служит для глобального управления шиной данных
class EventBusSupervisor {
  final List<EventCallback> _eventCallbacks = <EventCallback>[];
  final List<EventBusExceptionCallback> _exceptionCallbacks =
      <EventBusExceptionCallback>[];

  final EventBus _eventBus = EventBus();

  /// Добавить событие
  static void emit(Event event) => _instance._eventBus.emit(event);

  /// Закрыть шину данных
  /// ВНИМАНИЕ, ЭТО НЕОБРАТИМО
  static Future<void> close() => _instance._eventBus.close();

  /// Поток событий
  static Stream<Event> get events => _instance._eventBus.events;

  /// Поток ошибок
  static Stream<EventBusException> get errors => _instance._eventBus.errors;

  /// Добавить в список коллбэк вызываемый на каждое событие
  static void addEventCallback(EventCallback eventCallback) =>
      _instance._eventCallbacks.add(eventCallback);

  /// Добавить в список коллбэк вызываемый на каждую ошибку
  static void addErrorCallback(EventBusExceptionCallback errorCallback) =>
      _instance._exceptionCallbacks.add(errorCallback);

  void _onEvent(Event event) =>
      _eventCallbacks.forEach((EventCallback callback) => callback(event));

  void _onError(EventBusException error) => _exceptionCallbacks
      .forEach((EventBusExceptionCallback callback) => callback(error));

  static final EventBusSupervisor _instance = EventBusSupervisor._();
  EventBusSupervisor._() {
    _eventBus.events.forEach(_onEvent);
    _eventBus.errors.forEach(_onError);
  }
}
