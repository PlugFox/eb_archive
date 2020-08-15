import 'dart:async';

import '../models/message.dart';
import '../models/transition.dart';
import '../utils/normalize_topic.dart';

///
class WhereMessageTransitionTransformer<PrevMessage extends Message, NextMessage extends Message>
    extends StreamTransformerBase<Message, Transition<PrevMessage, NextMessage>> {
  final bool _cancelOnError;
  final bool _onlyCompletely;
  final String _topic;

  ///
  WhereMessageTransitionTransformer({String topic = '*', bool onlyCompletely = false, bool cancelOnError = false})
    : _topic = normalizeTopic(topic)
    , _cancelOnError = cancelOnError ?? false
    , _onlyCompletely = onlyCompletely ?? false;

  ///
  const WhereMessageTransitionTransformer.all({bool onlyCompletely = false, bool cancelOnError = false})
    : _topic = '*'
    , _cancelOnError = cancelOnError ?? false
    , _onlyCompletely = onlyCompletely ?? false;

  ///
  @override
  Stream<Transition<PrevMessage, NextMessage>> bind(Stream<Message> stream) {
    PrevMessage prevMessage;
    StreamSubscription<Message> subscription;
    final controller = StreamController<Transition<PrevMessage, NextMessage>>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<Transition<PrevMessage, NextMessage>>;
    subscription = stream.listen(
          (msg) {
        try {
          if (msg.topic != '*' && msg.topic != _topic) return;
          if (msg is NextMessage && !(_onlyCompletely && prevMessage == null)) {
            controller.add(
                Transition<PrevMessage, NextMessage>(prev: prevMessage, next: msg));
          }
          if (msg is PrevMessage) {
            prevMessage = msg;
          }
        } on dynamic catch (e, s) {
          controller.addError(e, s);
        }
      },
      onError: controller.addError,
      onDone: controller.close,
      cancelOnError: _cancelOnError,
    );
    return stream.isBroadcast
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}

/// Поток фильтрованных смен событий
/// onlyCompletely - возвращать только полную смену,
/// с определенным предыдущим событием
/// Укажите дженерики для фильтрации
extension WhereTransitionExtension on Stream<Message> {
  Stream<Transition<PrevMessage, NextMessage>>
    whereTransition<PrevMessage extends Message, NextMessage extends Message>({
      String topic = '*',
      bool onlyCompletely = false,
      bool cancelOnError = false,
    }) =>
      transform(
        WhereMessageTransitionTransformer<PrevMessage, NextMessage>(
          topic: topic,
          onlyCompletely: onlyCompletely,
          cancelOnError: cancelOnError,
        ),
      );
}
