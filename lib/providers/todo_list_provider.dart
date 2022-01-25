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
  final http.Client client;

  TodoListProvider([http.Client? client])
    : this.client = client ?? http.Client();

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> getTodos({Function(String)? onError}) async {
    _isBusy = true;

    try {
      final http.Response response = await client.get(Uri.parse('http://localhost:3000/'));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> list = jsonDecode(response.body).cast<Map<String, dynamic>>();
        _todos = list.map<Todo>((json) => Todo.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));
        if (onError != null) {
          onError(json['error'] as String);
        }
      }
    } catch (error) {
      if (onError != null) {
        onError(error.toString());
      }
    } finally {
      _isBusy = false;
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  Future<void> addTodo(String text, {Function? onSuccess, Function(String)? onError}) async {
    try {
      final http.Response response = await client.post(
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
        if (onError != null) {
          onError(json['error'] as String);
        }
      }
    } catch (error) {
      if (onError != null) {
        onError(error.toString());
      }
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  Future<void> toggleTodo(int id, bool isDone, {Function(String)? onError}) async {
    try {
      final http.Response response = await client.post(
        Uri.parse('http://localhost:3000/toggle'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'isDone': isDone,
        }),
      );

      final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200) {
        _todos = _todos.map<Todo>((todo) => todo.id == id ? Todo.fromJson(json) : todo).toList();
      } else {
        if (onError != null) {
          onError(json['error'] as String);
        }
      }
    } catch (error) {
      if (onError != null) {
        onError(error.toString());
      }
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  Future<void> deleteTodo(int id, {Function(String)? onError}) async {
    try {
      final http.Response response = await client.post(
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
        if (onError != null) {
          onError(json['error'] as String);
        }
      }
    } catch (error) {
      if (onError != null) {
        onError(error.toString());
      }
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }
}
