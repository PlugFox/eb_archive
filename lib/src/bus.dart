import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'models/models.dart';
import 'transformers/transformers.dart';

/// TODO: реализовать возможность распределения по изолятам (при этом оставить поддержку веба)
/// Менеджеры ответственные за общение между изолятами с основным потоком
///
/// В вебе реализация через Worker (отправка - postMessage, прием - onMessage)
/// В io реализация через Isolate (отправка - SendPort send, прием - listen)

/// TODO: шаблон адаптера для интеграции с MQ

/// TODO: в фильтрации сообщений проверять не по точному соответсвию, а по регулярке
/// например 'logic/login/*'

/// Функция принимающая Message и возвращающая void
typedef EventBusMW = void Function(Message);

/// Функция принимающая MessageBusError и возвращающая void
typedef EventBusExceptionMW = void Function(EventBusException);

/// Event Bus
@immutable
class EventBus implements Publisher, Subscriber, ExceptionSubscriber {

  /// Контроллер шины
  static final StreamController<Message> _queue = StreamController<Message>.broadcast();

  /// Очередь мидлварей сообщений
  final Queue<EventBusMW> _messageMW = Queue<EventBusMW>();

  /// Очередь мидлварей ошибок
  final Queue<EventBusExceptionMW> _exceptionMW = Queue<EventBusExceptionMW>();

  /// Получить объект синглтона шины данных
  factory EventBus() => _instance;
  static final EventBus _instance = EventBus._internalSingleton();
  EventBus._internalSingleton() {
    messages.forEach(_onMessage);
    errors.forEach(_onError);
  }

  /// '*' - означает получение всех сообщений подписчиком
  @override
  String get topic => '*';

  @override
  Stream<Message> get messages =>
    _queue.stream.handleError((Object _) => null); // ignore: avoid_types_on_closure_parameters

  @override
  Stream<EventBusException> get errors => _queue.stream.transform<EventBusException>(
      StreamTransformer<Message, EventBusException>.fromHandlers(
        handleData: (_, __) => null,
        handleError: (error, stackTrace, sink) =>
            sink.add(EventBusException(error: error, stackTrace: stackTrace)),
      ));

  @override
  void emit(Message nextMsg) {
    if (_queue.isClosed) {
      assert(() {
        throw StateError('Cannot add messages in Event Bus after closing');
      }(), 'Handle exceptions in debug mode');
      return;
    }
    try {
      _queue.add(nextMsg);
    // ignore: avoid_types_on_closure_parameters
    } on dynamic catch (error, stackTrace) {
      _queue.addError(error, stackTrace);
      assert(() {
        throw EventBusException(error: error, stackTrace: stackTrace);
      }(), 'Handle exceptions in debug mode');
    }
  }

  @override
  Stream<MessageType> whereMessages<MessageType extends Message>([String topic = '*']) =>
      messages.whereMessage<MessageType>(topic: topic);

  @override
  Stream<Transition<PrevMessage, NextMessage>>
    whereTransition<PrevMessage extends Message, NextMessage extends Message>
      ({
        String topic = '*',
        bool onlyCompletely = false,
      }) =>
        messages.whereTransition<PrevMessage, NextMessage>(
            topic: topic,
            onlyCompletely: onlyCompletely,
        );

  /// Добавить в очередь мидлварей метод вызываемый на каждое событие
  void addMessageMW(EventBusMW msgCallback) =>
      _messageMW.add(msgCallback);

  /// Добавить в очередь мидлварей методы вызываемые на каждое событие
  void addAllMessageMW(List<EventBusMW> msgCallbacks) =>
      _messageMW.addAll(msgCallbacks);

  /// Добавить в очередь мидлварей метод вызываемый на каждую ошибку
  void addErrorMW(EventBusExceptionMW errorCallback) =>
      _exceptionMW.add(errorCallback);

  /// Закрыть шину данных
  /// !!! ВНИМАНИЕ, ЭТО НЕОБРАТИМО !!!
  @protected
  Future<void> kill() => _queue.close();

  Future<void> _onMessage(Message msg) {
    final iterator = _messageMW.iterator;
    final middleware = Future.doWhile(() {
      if (!iterator.moveNext()) return false;
      if (iterator.current == null) return true;
      iterator.current(msg);
      return true;
    });
    return middleware;
  }

  Future<void> _onError(EventBusException error) {
    final iterator = _exceptionMW.iterator;
    final middleware = Future.doWhile(() {
      if (!iterator.moveNext()) return false;
      if (iterator.current == null) return true;
      iterator.current(error);
      return true;
    });
    return middleware;
  }
}