import 'package:meta/meta.dart';

/// Ошибка шины
@immutable
class EventBusException implements Exception {
  /// Error
  final Object error;

  /// StackTrace
  final StackTrace stackTrace;

  /// Описание ошибки
  String get message => toString();

  /// Иммутабельно
  const EventBusException({@required this.error, this.stackTrace});

  @override
  String toString() =>
    stackTrace == null 
    ? 'Unhandled error $error occurred in EventBus.'
    : 'Unhandled error $error occurred in EventBus.\n'
      '${stackTrace ?? ''}';
}