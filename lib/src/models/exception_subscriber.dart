import 'package:meta/meta.dart';

import '../bus.dart';
import '../models/exception.dart';

/// Приемник ошибок из шины данных
@immutable
class ExceptionSubscriber {
  /// Поток ошибок
  final Stream<EventBusException> errors = EventBus().errors;

  /// Приемник ошибок из шины данных
  ExceptionSubscriber();
}
