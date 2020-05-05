import 'dart:async';

import 'transition.dart';

///
class WhereMessageTypeTransformer<MessageType extends Message> implements StreamTransformer<Message, MessageType> {
  final bool _cancelOnError;
  final String _topic;

  ///
  WhereMessageTypeTransformer({String topic = '*', bool cancelOnError = false})
      : assert(topic is String && topic.isNotEmpty)
      , _topic = (topic?.isEmpty ?? true) ? '*' : topic
      , _cancelOnError = cancelOnError ?? false;

  ///
  const WhereMessageTypeTransformer.all({bool cancelOnError = false})
      : _topic = '*'
      , _cancelOnError = cancelOnError ?? false;

  ///
  @override
  Stream<MessageType> bind(Stream<Message> stream) {
    StreamSubscription<Message> subscription;
    final SynchronousStreamController<MessageType> controller = StreamController<MessageType>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<MessageType>;
    subscription = stream.listen(
      (Message msg) {
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
class WhereMessageTransitionTransformer<PrevMessage extends Message, NextMessage extends Message>
    extends StreamTransformerBase<Message, Transition<PrevMessage, NextMessage>> {
  final bool _cancelOnError;
  final bool _onlyCompletely;
  final String _topic;

  ///
  WhereMessageTransitionTransformer(
      {String topic = '*', bool onlyCompletely = false, bool cancelOnError = false})
      : assert(topic is String && topic.isNotEmpty)
      , _topic = (topic?.isEmpty ?? true) ? '*' : topic
      , _cancelOnError = cancelOnError ?? false
      , _onlyCompletely = onlyCompletely ?? false;
  
  ///
  const WhereMessageTransitionTransformer.all(
      {bool onlyCompletely = false, bool cancelOnError = false})
      : _topic = '*'
      , _cancelOnError = cancelOnError ?? false
      , _onlyCompletely = onlyCompletely ?? false;

  ///
  @override
  Stream<Transition<PrevMessage, NextMessage>> bind(Stream<Message> stream) {
    PrevMessage prevMessage = null;
    StreamSubscription<Message> subscription;
    final SynchronousStreamController<Transition<PrevMessage, NextMessage>>
        controller = StreamController<Transition<PrevMessage, NextMessage>>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<Transition<PrevMessage, NextMessage>>;
    subscription = stream.listen(
      (Message msg) {
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
