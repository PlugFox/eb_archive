import 'dart:async';

import '../models/message.dart';
import '../utils/normalize_topic.dart';

///
class WhereMessageTypeTransformer<MessageType extends Message> implements StreamTransformer<Message, MessageType> {
  final bool _cancelOnError;
  final String _topic;

  ///
  WhereMessageTypeTransformer({String topic = '*', bool cancelOnError = false})
    : _topic = normalizeTopic(topic)
    , _cancelOnError = cancelOnError ?? false;

  ///
  const WhereMessageTypeTransformer.all({bool cancelOnError = false})
    : _topic = '*'
    , _cancelOnError = cancelOnError ?? false;

  ///
  @override
  Stream<MessageType> bind(Stream<Message> stream) {
    StreamSubscription<Message> subscription;
    final controller = StreamController<MessageType>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<MessageType>;
    subscription = stream.listen(
          (msg) {
        try {
          if (_topic != '*' && msg.topic != _topic) return;
          if (msg is MessageType) {
            controller.add(msg);
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

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() =>
      StreamTransformer.castFrom<Message, MessageType, RS, RT>(this);
}

///
extension WhereMessageExtension on Stream<Message> {
  Stream<MessageType> whereMessage<MessageType extends Message>({String topic = '*', bool cancelOnError = false}) =>
      transform(WhereMessageTypeTransformer<MessageType>(topic: topic, cancelOnError: cancelOnError));
}
