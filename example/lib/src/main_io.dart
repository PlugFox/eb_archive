// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:io' as io;
import 'dart:isolate';

import 'package:eb/eb.dart';

import 'logic/logic.dart' as logic;
import 'ui/app.dart' as app;

/// Запуск приложения как io
void runner() =>
  main();

void main([List<String> args]) {
  /// Инициализация общения с изолятом
  final receivePort = ReceivePort();
  final dataFromIsolate = receivePort.asBroadcastStream();
  final isolate = Isolate.spawn<SendPort>(_handshakeWithLogic, receivePort.sendPort);
  dataFromIsolate
      .firstWhere((dynamic element) => element is SendPort)
      .then((dynamic sendPort) => eventBus.addMessageMW((msg)  {
        if (!msg.topic.startsWith('logic/')) return;
        sendPort.send(msg.toJson());
      })); // ignore: avoid_annotating_with_dynamic
  dataFromIsolate
      .where((dynamic msg) => msg is Map<String, dynamic> && msg.containsKey('message')) // ignore: avoid_annotating_with_dynamic
      .map((dynamic msg) => Message.fromJson(msg as Map<String, dynamic>)) // ignore: avoid_annotating_with_dynamic
      .forEach(eventBus.emit);

  /// Запуск приложения
  app.start();
}

void _handshakeWithLogic(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final dataFromMain = receivePort.asBroadcastStream();
  eventBus.addMessageMW((msg)  {
    if (!msg.topic.startsWith('ui/')) return;
    sendPort.send(msg.toJson());
  });
  dataFromMain
      .where((dynamic msg) => msg is Map<String, dynamic> && msg.containsKey('message')) // ignore: avoid_annotating_with_dynamic
      .map((dynamic msg) => Message.fromJson(msg as Map<String, dynamic>)) // ignore: avoid_annotating_with_dynamic
      .forEach(eventBus.emit);
  logic.start();
}