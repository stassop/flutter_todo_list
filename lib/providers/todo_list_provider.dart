import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Todo {
  final int id;
  final String text;
  final bool isDone;

  const Todo({
    required this.id,
    required this.text,
    required this.isDone,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      text: json['text'] as String,
      isDone: json['isDone'] as bool,
    );
  }
}

class TodoListProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _isBusy = false;
  // getters
  bool get isBusy => _isBusy;
  List<Todo> get todos => _todos;

  void fetchTodos({required Function(String) onError}) async {
    _isBusy = true;

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/'));
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> list = jsonDecode(response.body).cast<Map<String, dynamic>>();
        _todos = list.map<Todo>((json) => Todo.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));
        onError(json['error'] as String);
      }
    } catch (error) {
      onError(error.toString());
    } finally {
      _isBusy = false;
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void addTodo({required String text, required Function(String) onError, Function()? onSuccess}) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/add'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': text,
        }),
      );

      final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200) {
        _todos.add(Todo.fromJson(json));
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        onError(json['error'] as String);
      }
    } catch (error) {
      onError(error.toString());
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void toggleTodo({required int id, required Function(String) onError}) async {
    final bool isDone = _todos.firstWhere((todo) => todo.id == id).isDone;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/toggle'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'isDone': !isDone,
        }),
      );

      final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200) {
        _todos = _todos.map<Todo>((todo) => todo.id == id ? Todo.fromJson(json) : todo).toList();
      } else {
        onError(json['error'] as String);
      }
    } catch (error) {
      onError(error.toString());
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void deleteTodo({required int id, required Function(String) onError}) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/delete'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'id': id}),
      );

      if (response.statusCode == 200) {
        _todos.removeWhere((todo) => todo.id == id);
      } else {
        final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));
        onError(json['error'] as String);
      }
    } catch (error) {
      onError(error.toString());
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }
}
