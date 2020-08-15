import 'package:eb/eb.dart';
import 'package:test/test.dart';

//final throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  test('Event Bus constructor', () {
    expect(() => EventBus(), returnsNormally);
  });

  test('Identical objects', () {
    final a = EventBus();
    final b = EventBus();
    final c = eventBus;
    expect(identical(a, b), true);
    expect(identical(b, c), true);
  });

  test('Can emit', () {
    expect(() => eventBus.emit(Message('*')), returnsNormally);
  });

  test('Can not emit with empty or null topic', () {
    expect(() => eventBus.emit(Message('')), returnsNormally);
    expect(() => eventBus.emit(Message(null)), returnsNormally);
  });
}