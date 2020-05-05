import 'dart:collection';

import 'bus.dart';
import 'mixins.dart';

/// Служит для глобального управления шиной данных
class MessageBusSupervisor {
  final Queue<MessageMW> _messageMW = Queue<MessageMW>();
  final Queue<MessageBusExceptionMW> _exceptionMW =
      Queue<MessageBusExceptionMW>();

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

  /// Добавить в очередь мидлварей метод вызываемый на каждое событие
  static void addMessageMW(MessageMW msgCallback) =>
      _instance._messageMW.add(msgCallback);

  /// Добавить в очередь мидлварей методы вызываемые на каждое событие
  static void addAllMessageMW(List<MessageMW> msgCallbacks) =>
      _instance._messageMW.addAll(msgCallbacks);
  
  /// Добавить в очередь мидлварей метод вызываемый на каждую ошибку
  static void addErrorMW(MessageBusExceptionMW errorCallback) =>
      _instance._exceptionMW.add(errorCallback);

  Future<void> _onMessage(Message msg) {
    Iterator<MessageMW> iter = _messageMW.iterator;
    Future<void> mws = Future.doWhile(() {
      if (!iter.moveNext()) return false;
      if (iter.current == null) return true;
      iter.current(msg);
      return true;
    });
    return mws;
  }

  Future<void> _onError(EventBusException error) {
    Iterator<MessageBusExceptionMW> iter = _exceptionMW.iterator;
    Future<void> mws = Future.doWhile(() {
      if (!iter.moveNext()) return false;
      if (iter.current == null) return true;
      iter.current(error);
      return true;
    });
    return mws;
  }

  static final MessageBusSupervisor _instance = MessageBusSupervisor._();
  MessageBusSupervisor._() {
    _eventBus.messages.forEach(_onMessage);
    _eventBus.errors.forEach(_onError);
  }
}
