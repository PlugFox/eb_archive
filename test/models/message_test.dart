import 'package:eb/eb.dart';
import 'package:test/test.dart';


void main() {
  test('Message constructor', () {
    expect(() => Message(), returnsNormally);
    expect(() => Message().toString(), returnsNormally);
    expect(Message().toString() is String, true);
  });

  test('Not identical message with same constructor, but equal', () {
    final a = Message();
    final b = Message();
    expect(identical(a, b), false);
    expect(a == b, true);
  });

  test('Can convert to JSON', () {
    expect(() => Message().toJson(), returnsNormally);
    expect(Message().toJson() is Map<String, dynamic>, true);
    expect(Message().toJson().containsKey('message'), true);
    expect(Message().toJson()['message'].containsKey('topic'), true);
    expect(Message().toJson()['message'].containsKey('data'), true);
  });

  test('Can create from JSON', () {
    const json = {'message': {'topic': '*', 'data': null}};
    expect(() => Message.fromJson(json), returnsNormally);
    expect(Message.fromJson(json).topic == '*', true);
    expect(Message.fromJson(json).hasData, false);
  });
}