// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:html' as html;
import 'package:eb/eb.dart';

import 'ui/app.dart' as app;

/// Запуск для веба
void runner() =>
  main();

void main() {
  final href = html.window.location.href;
  if (href.contains('/') && !href.endsWith('/#/')) {
    html.window.location.href = '/';
  }

  final worker = html.Worker('logic.dart.js');

  eventBus.addMessageMW((msg) {
    if (!msg.topic.startsWith('logic/')) return;
    worker.postMessage(msg.toJson());
  });
  worker.onMessage
      .map<dynamic>((event) => event?.data)
      .where((dynamic data) => data is Map && data.containsKey('message'))
      .map((dynamic data) {
        final msg = data.remove('message') as Map;
        return Message(msg.remove('topic') as String, msg.remove('data'));
      }).forEach(eventBus.emit);

  app.start();
}
