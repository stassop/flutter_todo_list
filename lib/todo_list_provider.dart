import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

class Todo {
  final int id;
  final bool isDone;
  final String text;

  const Todo({
    required this.id,
    required this.isDone,
    required this.text,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      isDone: json['isDone'] as bool,
      text: json['text'] as String,
    );
  }
}

class ResponseError {
  final String error;

  const ResponseError({
    required this.error,
  });

  factory ResponseError.fromJson(Map<String, dynamic> json) {
    return ResponseError(
      error: json['error'] as String,
    );
  }
}

class TodoListProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String? _error = null;
  String _text = '';
  bool _isFetching = false;
  bool _isAddTodoVisible = false;

  bool get isFetching => _isFetching;

  List<Todo> get todos => _todos;

  String? get error => _error;

  bool get hasError => _error != null;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String get text => _text;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

  bool get hasText => _text.length > 0;

  void clearText() {
    _text = '';
    notifyListeners();
  }

  bool get isAddTodoVisible => _isAddTodoVisible;

  void toggleAddTodo() {
    _isAddTodoVisible = !_isAddTodoVisible;
    notifyListeners();
  }

  void fetchTodos() async {
    _isFetching = true;
    _error = null;

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/'));
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> list = jsonDecode(response.body).cast<Map<String, dynamic>>();
        _todos = list.map<Todo>((json) => Todo.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));
        _error = ResponseError.fromJson(json).error;
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isFetching = false;
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void addTodo() async {
    _error = null;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/add'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': _text,
        }),
      );

      final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200) {
        _todos.add(Todo.fromJson(json));
        _isAddTodoVisible = false;
        _text = '';
      } else {
        _error = ResponseError.fromJson(json).error;
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void toggleTodo(int id) async {
    _error = null;
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
        _error = ResponseError.fromJson(json).error;
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }

  void deleteTodo(int id) async {
    _error = null;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/delete'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        _todos.removeWhere((todo) => todo.id == id);
      } else {
        final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(response.body));
        _error = ResponseError.fromJson(json).error;
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      notifyListeners(); // notify widgets to rebuild.
    }
  }
}
