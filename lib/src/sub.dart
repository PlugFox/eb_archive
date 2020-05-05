import 'package:meta/meta.dart';

import 'bus.dart';
import 'filters.dart';
import 'transition.dart';

/// Объект для подписки на определенный топик
class Sub<MessageType extends Message> {  
  static final EventBus _eventBus = EventBus();

  /// Топик подписчика
  final String topic;

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  final Stream<MessageType> messages;
  
  ///
  Sub({@required String topic})
    : assert(topic is String && topic.isNotEmpty)
    , topic = (topic?.isEmpty ?? true) ? '*' : topic
    , messages = _eventBus.messages.transform<MessageType>(WhereMessageTypeTransformer<MessageType>(topic: topic));
    
  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevMessage, NextMessage>>
      whereTransition<PrevMessage extends MessageType, NextMessage extends MessageType>(
              {String topic = '*', bool onlyCompletely = false}) =>
          _eventBus.messages.transform<Transition<PrevMessage, NextMessage>>(
              WhereMessageTransitionTransformer<PrevMessage, NextMessage>(
                  topic: topic,
                  onlyCompletely: onlyCompletely));
}