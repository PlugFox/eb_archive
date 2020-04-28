import 'bus.dart';
import 'mixins.dart';

/// Служит для глобального управления шиной данных
class MessageBusSupervisor {
  final List<MessageCallback> _messageCallbacks = <MessageCallback>[];
  final List<MessageBusExceptionCallback> _exceptionCallbacks =
      <MessageBusExceptionCallback>[];

  final EventBus _eventBus = EventBus();

  /// Добавить событие
  static void emit(Message msg) => _instance._eventBus.emit(msg);

  /// Закрыть шину данных
  /// ВНИМАНИЕ, ЭТО НЕОБРАТИМО
  static Future<void> kill() => _instance._eventBus.kill();

  /// Поток событий
  static Stream<Message> get messages => _instance._eventBus.messages;

  /// Поток ошибок
  static Stream<EventBusException> get errors => _instance._eventBus.errors;

  /// Добавить в список коллбэк вызываемый на каждое событие
  static void addMessageCallback(MessageCallback msgCallback) =>
      _instance._messageCallbacks.add(msgCallback);

  /// Добавить в список коллбэки вызываемый на каждое событие
  static void addMessageCallbacks(List<MessageCallback> msgCallbacks) =>
      _instance._messageCallbacks.addAll(msgCallbacks);
  
  /// Добавить в список коллбэк вызываемый на каждую ошибку
  static void addErrorCallback(MessageBusExceptionCallback errorCallback) =>
      _instance._exceptionCallbacks.add(errorCallback);

  void _onMessage(Message msg) =>
      _messageCallbacks.forEach((MessageCallback callback) => callback(msg));

  void _onError(EventBusException error) => _exceptionCallbacks
      .forEach((MessageBusExceptionCallback callback) => callback(error));

  static final MessageBusSupervisor _instance = MessageBusSupervisor._();
  MessageBusSupervisor._() {
    _eventBus.messages.forEach(_onMessage);
    _eventBus.errors.forEach(_onError);
  }
}
