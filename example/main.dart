// ignore_for_file: avoid_print

import 'package:eb/eb.dart';

class A with Subscriber {
  A() {
    events.forEach((Event e) => print('A gotcha $e')); 
  }
}
  
class B with Subscriber {}

class C with Publisher {}

void main() {
  // Supervisor for whole app and logs
  EventBusSupervisor.addEventCallbacks(<EventCallback>[
    (Event e) => print('Supervisor gotcha $e #2'),
    (Event e) => print('Supervisor gotcha $e #1'),
  ]);

  // Domains/Subsystems/Widgets
  A();
  B()..onEvent((Event e) => print('B gotcha $e'));
  C()..emit(const Event());

  // Permanent bus destruction
  EventBusSupervisor.kill();
}