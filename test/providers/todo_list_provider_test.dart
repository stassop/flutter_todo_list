import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_todo_list/providers/todo_list_provider.dart';

import 'todo_list_provider_test.mocks.dart';

// Generic mock function class
class MockFunction extends Mock {
  void call();
}

class MockOnError extends Mock {
  void call(String error);
}

// Generate a MockClient using the Mockito package.
// To generate mocks run `flutter pub run build_runner build`
@GenerateMocks([http.Client])
void main() {
  group('TodoListProvider', () {
    final client = MockClient();
    final notifyListeners = MockFunction();
    final provider = TodoListProvider(client)
      ..addListener(notifyListeners);

    setUp(() {
      reset(notifyListeners); // reset before each test
    });

    test('Should have correct initial values', () {
      expect(provider.todos.length, 0);
      expect(provider.isBusy, false);
    });

    test('Should get todos and handle success', () async {
      when(client
        .get(Uri.parse('http://localhost:3000/')))
        .thenAnswer((_) async => http.Response('[{"text": "First todo", "id": 1, "isDone": false}]', 200));

      Future<void> getTodos = provider.getTodos();

      expect(provider.isBusy, true);

      await getTodos;

      expect(provider.isBusy, false);
      expect(provider.todos.length, 1);
      verify(notifyListeners()).called(1);
    });

    test('Should get todos and handle error', () async {
      final onError = MockOnError();
      when(client
        .get(Uri.parse('http://localhost:3000/')))
        .thenAnswer((_) async => http.Response('{"error": "Oops!"}', 500));

      await provider.getTodos(onError: onError);

      verify(onError('Oops!')).called(1);
      verify(notifyListeners()).called(1);
    });

    test('Should add todos', () async {
      final onSuccess = MockFunction();
      when(client
        .post(
          Uri.parse('http://localhost:3000/add'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'text': 'Second todo',
          }),
        ))
        .thenAnswer((_) async => http.Response('{"text": "Second todo", "id": 2, "isDone": false}', 200));

      await provider.addTodo('Second todo', onSuccess: onSuccess);

      expect(provider.todos.length, 2);
      verify(onSuccess()).called(1);
      verify(notifyListeners()).called(1);
    });

    test('Should toggle todos', () async {
      when(client
        .post(
          Uri.parse('http://localhost:3000/toggle'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'id': 1,
            'isDone': true,
          }),
        ))
        .thenAnswer((_) async => http.Response('{"text": "First todo", "id": 1, "isDone": true}', 200));

      await provider.toggleTodo(1, true);

      expect(provider.todos[0].isDone, true);
      verify(notifyListeners()).called(1);
    });

    test('Should delete todos', () async {
      when(client
        .post(
          Uri.parse('http://localhost:3000/delete'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{'id': 1}),
        ))
        .thenAnswer((_) async => http.Response('{"text": "First todo", "id": 1, "isDone": true}', 200));

      await provider.deleteTodo(1);

      expect(provider.todos.length, 1);
      verify(notifyListeners()).called(1);
    });
  });
}
