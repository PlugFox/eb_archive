
import 'dart:async';

import 'package:eb/eb.dart';

export 'package:eb/eb.dart';

int incrementState = 0;

void start() =>
  runZoned(() async {
    // реакция на 'logic/increment' топик
    await for (final _ in eventBus.whereMessages('logic/increment')) {
      incrementState++;
      eventBus.emit(Message('ui/increment-state', incrementState));
    }
  });