import 'bus.dart';
import 'exception.dart';
import 'filters.dart';
import 'transition.dart';

export 'exception.dart';
export 'transition.dart';

/// Функция принимающая Message и возвращающая void
typedef MessageMW = void Function(Message);
/// Функция принимающая MessageBusError и возвращающая void
typedef MessageBusExceptionMW = void Function(EventBusException);

/// Миксин для отправителя событий в шину данных
mixin Publisher {
  static final EventBus _eventBus = EventBus();

  /// Добавить событие
  void emit(Message msg) => _eventBus.emit(msg);
}

/// Миксин для приемника событий из шины данных
mixin Subscriber {
  static final EventBus _eventBus = EventBus();

  /// Поток событий
  final Stream<Message> messages = _eventBus.messages;

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  Stream<MessageType> whereMessages<MessageType extends Message>([String topic = '*']) =>
      messages.transform(WhereMessageTypeTransformer<MessageType>(topic: topic));

  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevMessage, NextMessage>>
      whereTransition<PrevMessage extends Message, NextMessage extends Message>(
              {String topic = '*', bool onlyCompletely = false}) =>
          messages.transform(
              WhereMessageTransitionTransformer<PrevMessage, NextMessage>(
                  topic: topic,
                  onlyCompletely: onlyCompletely));

  /// Коллбэк на событие
  /// Укажите дженерик для фильтрации
  void onMessage<MessageType extends Message>(MessageMW callback, [String topic = '*']) =>
      whereMessages<MessageType>(topic).forEach(callback);
}

/// Миксин для приемника ошибок из шины данных
mixin ExceptionSubscriber {
  /// Поток ошибок
  final Stream<EventBusException> errors = EventBus().errors;

  /// Коллбэк на ошибку
  void onError(MessageBusExceptionMW callback) =>
      errors.forEach(callback);
}
