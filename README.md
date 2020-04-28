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
    messages.forEach((Message e) => print('A gotcha $e')); 
  }
}
  
class B with Subscriber {}

class C with Publisher, Subscriber {}

class D with Publisher {}

void main() {
  // Supervisor for whole app and logs
  MessageBusSupervisor.addMessageCallbacks(<MessageCallback>[
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
```  
  
  