// ignore_for_file: avoid_print

import 'package:eb/eb.dart';

class A with Subscriber {
  A() {
    messages.forEach((Message e) => print('A gotcha $e')); 
  }
}
  
class B with Subscriber {}

class C with Publisher, Subscriber {}

class D with Publisher {}

void main() {
  // Supervisor for whole app and logs
  MessageBusSupervisor.addMessageCallbacks(<MessageMW>[
    (Message e) => print('Supervisor gotcha $e #1'),
    (Message e) => print('Supervisor gotcha $e #2'),
  ]);

  // Domains/Subsystems/Widgets
  A();
  B()..onMessage((Message e) => print('B gotcha $e'));
  C()..onMessage((Message e) => print('C gotcha $e'), topic: 'd')..emit(const Message('c'));
  D()..emit(const Message('d'));

  // Permanent bus destruction
  MessageBusSupervisor.kill();
}