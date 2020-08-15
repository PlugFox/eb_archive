import 'package:meta/meta.dart';


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
    @required this.next, // ignore: always_put_required_named_parameters_first
  }) : assert(next != null, 'Next message must not be null');

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
