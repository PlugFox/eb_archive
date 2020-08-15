
import 'package:meta/meta.dart';

import '../bus.dart';
import 'message.dart';

/// Отправитель событий в шину данных
@immutable
class Publisher<MessageType extends Message> {
  static final EventBus _eventBus = EventBus();

  /// Отправитель событий в шину данных
  const Publisher();

  /// Добавить событие
  void emit(MessageType msg) => _eventBus.emit(msg);
}