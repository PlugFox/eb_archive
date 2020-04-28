# EB  
  
### About  
Implementation of event-driven [publish–subscribe pattern](https://en.wikipedia.org/wiki/Publish-subscribe_pattern) with singleton Event Bus.

  
## Example:  
  
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
  EventBusSupervisor.addEventCallback((Event e) => print('Supervisor gotcha $e #1'));
  EventBusSupervisor.addEventCallback((Event e) => print('Supervisor gotcha $e #2'));

  final A a = A();
  final B b = B()..onEvent((Event e) => print('B gotcha $e'));

  final C c = C()..emit(const Event());

  EventBusSupervisor.close();
}
  
```  
  
  