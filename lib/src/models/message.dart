import 'package:meta/meta.dart';

import '../utils/normalize_topic.dart' show normalizeTopic;

/// Базовое событие для расширения
@immutable
class Message {
  /// Тема
  final String topic;

  /// Содержимое
  final Object data;

  /// Обладает содержимым
  bool get hasData => data != null;

  /// Всегда иммутабельно
  Message([String topic = '*', this.data])
    : topic = normalizeTopic(topic);

  /// Десериализовать из JSON
  factory Message.fromJson(Map<String, dynamic> map) =>
      Message(map['message']['topic'] as String, map['message']['data']);

  /// Сериализовать в JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': <String, dynamic>{
      'topic': topic,
      'data': data,
    },
  };

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
        other is Message &&
        runtimeType == other.runtimeType &&
        topic == other.topic &&
        data == other.data;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'Message { topic: $topic }';
}
