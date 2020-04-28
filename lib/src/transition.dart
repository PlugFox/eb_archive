import 'package:meta/meta.dart';

/// Базовое событие для расширения
@immutable
class Event {
  /// Тема
  final String topic;

  /// Содержимое
  final Object message;

  /// Всегда иммутабельно
  const Event([String topic = '*', this.message]) : topic = topic ?? '*';

  /// Десериализовать из JSON
  factory Event.fromJson(Map<String, dynamic> map) =>
      Event(map['event']['topic'] as String, map['event']['message']);

  /// Сериализовать в JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'event': <String, dynamic>{
          'topic': topic,
          'message': message,
        },
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          topic == other.topic &&
          message == other.message;

  @override
  int get hashCode => super.hashCode;
}

/// Смена событий
@immutable
class Transition<PrevEvent, NextEvent> {
  /// Предыдущее состояние
  final PrevEvent prev;

  /// Следущее событие
  final NextEvent next;

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
