import 'dart:async';

import 'transition.dart';

///
class WhereTypeTransformer<E, EType> implements StreamTransformer<E, E> {
  final bool _cancelOnError;

  /// 
  WhereTypeTransformer({bool cancelOnError = false})
    : _cancelOnError = cancelOnError ?? false;

  ///
  @override
  Stream<E> bind(Stream<E> stream) {
    StreamSubscription<E> subscription;
    final SynchronousStreamController<E> controller = 
      StreamController<E>(
        onCancel: () => subscription.cancel(),
        onPause: () => subscription.pause(),
        onResume: () => subscription.resume(),
        sync: true,
      ) as SynchronousStreamController<E>;
    subscription = stream.listen((E event) {
        try {
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
      StreamTransformer.castFrom<E, E, RS, RT>(this);
}


///
class WhereTransitionTransformer<E, PrevEType, NextEType> extends StreamTransformerBase<E, Transition<PrevEType, NextEType>> {
  final bool _cancelOnError;
  final bool _onlyCompletely;

  /// 
  const WhereTransitionTransformer({bool onlyCompletely = false, bool cancelOnError = false})
    : _cancelOnError = cancelOnError ?? false
    , _onlyCompletely = onlyCompletely ?? false;

  ///
  @override
  Stream<Transition<PrevEType, NextEType>> bind(Stream<E> stream) {
    PrevEType prevEvent = null;
    StreamSubscription<E> subscription;
    final SynchronousStreamController<Transition<PrevEType, NextEType>> controller = 
      StreamController<Transition<PrevEType, NextEType>>(
        onCancel: () => subscription.cancel(),
        onPause: () => subscription.pause(),
        onResume: () => subscription.resume(),
        sync: true,
      ) as SynchronousStreamController<Transition<PrevEType, NextEType>>;
    subscription = stream.listen((E event) {
        try {
          if (event is NextEType && !(_onlyCompletely && prevEvent == null)) {
            controller.add(Transition<PrevEType, NextEType>(prev: prevEvent, next: event));
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