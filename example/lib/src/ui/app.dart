import 'package:eb/eb.dart';
import 'package:flutter/material.dart';

void start() =>
  runApp(const App());

@immutable
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
    const MaterialApp(
      title: 'Event Bus example',
      home: Scaffold(
        floatingActionButton: PubWidget(),
        body: SafeArea(
          child: Center(
            child: SubWidget(),
          ),
        ),
      ),
    );
}

@immutable
class PubWidget extends StatelessWidget {
  const PubWidget({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
    FloatingActionButton(
      onPressed: () => eventBus.emit(Message('logic/increment')),
      child: const Icon(Icons.add_circle),
    );
}

@immutable
class SubWidget extends StatelessWidget {
  const SubWidget({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
    StreamBuilder<int>(
      initialData: 0,
      stream: eventBus.whereMessages('ui/increment-state').map<int>((msg) => msg.data as int),
      builder: (ctx, state) =>
          Text('Counter: ${state.data}'),
    );
}