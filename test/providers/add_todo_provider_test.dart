import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_todo_list/providers/add_todo_provider.dart';

// Generic mock function class
class MockFunction extends Mock {
  void call();
}

void main() {
  group('AddTodoProvider', () {
    final notifyListeners = MockFunction();
    final provider = AddTodoProvider()
      ..addListener(notifyListeners);

    setUp(() {
      reset(notifyListeners); // reset before each test
    });

    test('Should have correct initial values', () {
      expect(provider.text, '');
      expect(provider.isVisible, false);
    });

    test('Should add text', () {
      provider.text = 'Hi';

      expect(provider.text, 'Hi');
      expect(provider.hasText, true);
      verify(notifyListeners()).called(1);
    });

    test('Should clear text', () {
      provider.clear();

      expect(provider.text, '');
      expect(provider.hasText, false);
      verify(notifyListeners()).called(1);
    });

    test('Should toggle visibility', () {
      provider.toggle();

      expect(provider.isVisible, true);
      verify(notifyListeners()).called(1);
    });
  });
}
