# EB  
  
  
### About  
Event Manager implementing an event-driven [publish–subscribe pattern](https://en.wikipedia.org/wiki/Publish-subscribe_pattern) with singleton Event Bus.  
Inspired by message queue paradigm, message brokers.  
Designed for easy application scaling.  
  
  
---
  
### Example:  
  
```dart
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
```  
  
  