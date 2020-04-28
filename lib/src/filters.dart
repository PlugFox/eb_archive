import 'dart:async';

import 'transition.dart';

///
class WhereEventTypeTransformer<EType extends Event> implements StreamTransformer<Event, Event> {
  final bool _cancelOnError;
  final String _topic;

  ///
  WhereEventTypeTransformer({String topic = '*', bool cancelOnError = false})
      : _topic = (topic?.isEmpty ?? true) ? '*' : topic
      , _cancelOnError = cancelOnError ?? false;

  ///
  const WhereEventTypeTransformer.all({String topic = '*', bool cancelOnError = false})
      : _topic = '*'
      , _cancelOnError = cancelOnError ?? false;

  ///
  @override
  Stream<Event> bind(Stream<Event> stream) {
    StreamSubscription<Event> subscription;
    final SynchronousStreamController<Event> controller = StreamController<Event>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<Event>;
    subscription = stream.listen(
      (Event event) {
        try {
          if (event.topic != '*' && event.topic != _topic) return;
          if (event is EType) {
            controller.add(event);
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
      StreamTransformer.castFrom<Event, Event, RS, RT>(this);
}

///
class WhereEventTransitionTransformer<PrevEType extends Event, NextEType extends Event>
    extends StreamTransformerBase<Event, Transition<PrevEType, NextEType>> {
  final bool _cancelOnError;
  final bool _onlyCompletely;
  final String _topic;

  ///
  WhereEventTransitionTransformer(
      {String topic, bool onlyCompletely = false, bool cancelOnError = false})
      : _topic = (topic?.isEmpty ?? true) ? '*' : topic
      , _cancelOnError = cancelOnError ?? false
      , _onlyCompletely = onlyCompletely ?? false;
  
  ///
  const WhereEventTransitionTransformer.all(
      {bool onlyCompletely = false, bool cancelOnError = false})
      : _topic = '*'
      , _cancelOnError = cancelOnError ?? false
      , _onlyCompletely = onlyCompletely ?? false;

  ///
  @override
  Stream<Transition<PrevEType, NextEType>> bind(Stream<Event> stream) {
    PrevEType prevEvent = null;
    StreamSubscription<Event> subscription;
    final SynchronousStreamController<Transition<PrevEType, NextEType>>
        controller = StreamController<Transition<PrevEType, NextEType>>(
      onCancel: () => subscription.cancel(),
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      sync: true,
    ) as SynchronousStreamController<Transition<PrevEType, NextEType>>;
    subscription = stream.listen(
      (Event event) {
        try {
          if (event.topic != '*' && event.topic != _topic) return;
          if (event is NextEType && !(_onlyCompletely && prevEvent == null)) {
            controller.add(
                Transition<PrevEType, NextEType>(prev: prevEvent, next: event));
          }
          if (event is PrevEType) {
            prevEvent = event;
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
