import 'package:meta/meta.dart';

import '../bus.dart';
import '../transformers/where_message.dart';
import '../transformers/where_transition.dart';
import '../utils/normalize_topic.dart';
import 'message.dart';
import 'transition.dart';

/// Приемник событий из шины данных
@immutable
class Subscriber<MessageType extends Message> {
  static final EventBus _eventBus = EventBus();

  /// Топик подписчика
  final String topic;

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  final Stream<MessageType> messages;

  /// Подписчик для получения событий
  Subscriber([String topic = '*'])
    : topic = normalizeTopic(topic)
    , messages = _eventBus.messages.whereMessage<MessageType>(topic: topic);

  /// Поток фильтрованных событий
  /// Укажите дженерик для фильтрации
  Stream<SubMessageType> whereMessages<SubMessageType extends MessageType>([String topic]) =>
      messages.whereMessage<SubMessageType>(topic: topic ?? this.topic);

  /// Поток фильтрованных смен событий
  /// onlyCompletely - возвращать только полную смену,
  /// с определенным предыдущим событием
  /// Укажите дженерики для фильтрации
  Stream<Transition<PrevMessage, NextMessage>>
    whereTransition<PrevMessage extends MessageType, NextMessage extends MessageType>(
        {String topic, bool onlyCompletely = false}) =>
        _eventBus.messages.whereTransition<PrevMessage, NextMessage>(
            topic: topic ?? this.topic,
            onlyCompletely: onlyCompletely,
        );
}