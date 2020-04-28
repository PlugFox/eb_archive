import 'package:meta/meta.dart';

/// Базовое событие для расширения
@immutable
class Message {
  /// Тема
  final String topic;

  /// Содержимое
  final Object data;

  /// Всегда иммутабельно
  const Message([String topic = '*', this.data]) : topic = topic ?? '*';

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

/// Смена событий
@immutable
class Transition<PrevMessage, NextMessage> {
  /// Предыдущее состояние
  final PrevMessage prev;

  /// Следущее событие
  final NextMessage next;

  /// Обладает не только следущим событием,
  /// но и предыдущим.
  /// Тоесть содержит полностью оба события.
  bool get completely => prev != null;

  /// Всегда иммутабельно
  const Transition({
    this.prev,
    @required this.next,
  }) : assert(next != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition &&
          runtimeType == other.runtimeType &&
          prev == other.prev &&
          next == other.next;

  @override
  int get hashCode => next.hashCode ^ (prev?.hashCode ?? 0);

  @override
  String toString() => prev == null
      ? 'Transition { next: $next }'
      : 'Transition { prev: $prev, '
          'next: $next }';
}
