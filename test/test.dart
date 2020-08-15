// ignore_for_file: unnecessary_lambdas

import 'package:test/test.dart';

import 'bus/bus_test.dart' as bus_test;
import 'models/message_test.dart' as message;

void main() {
  group('Event Bus', () {
    bus_test.main();
  });
  group('Models', () {
    message.main();
  });
}