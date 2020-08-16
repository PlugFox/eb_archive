import 'dart:js';
import 'dart:html' as html;
import 'package:js/js.dart';
import 'package:eb/eb.dart' show Message, eventBus;
import 'package:eb_example/src/logic/logic.dart' as logic;

@JS()
@anonymous
class JSData {
  external JSMessage get message;
  external factory JSData({JSMessage message});
}

@JS()
@anonymous
class JSMessage {
  external String get topic;
  external dynamic get data;
  external factory JSMessage({String topic, dynamic data});
}

@JS()
@anonymous
abstract class MessageEvent {
  external dynamic get data;
}

@JS('postMessage')
external void postMessage(obj);

@JS('onmessage')
external void set onMessage(f);

//@JS("JSON.stringify")
//external String stringify(obj);

void main() {
  onMessage = allowInterop((event) {
    final e = event as MessageEvent;
    final jsData = e.data;
    if (jsData == null) return;
    final jsMessage = (jsData as JSData).message;
    if (jsMessage == null) return;
    eventBus.emit(Message(jsMessage.topic, jsMessage.data));
  });

  eventBus.addMessageMW((msg)  {
    if (!msg.topic.startsWith('ui/')) return;
    postMessage(
      JSData(
        message: JSMessage(
          topic: msg.topic,
          data: msg.data,
        ),
      ),
    );
  });

  logic.start();
}