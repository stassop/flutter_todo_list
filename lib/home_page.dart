import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/add_todo.dart';
import 'package:flutter_todo_list/todo_list.dart';
import 'package:flutter_todo_list/animated_fab.dart';
import 'package:flutter_todo_list/todo_list_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _addTodo() {
    Provider.of<TodoListProvider>(context, listen: false).addTodo();
  }

  void _toggleAddTodo() {
    Provider.of<TodoListProvider>(context, listen: false).toggleAddTodo();
  }

  void _showError({String? error, required VoidCallback onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oops!'),
          content: Text('$error'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                onDismiss();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListProvider>(
      builder: (context, provider, child) {
        if (provider.hasError) {
          Future.delayed(Duration.zero, () {
            _showError(error: provider.error, onDismiss: provider.clearError);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Todos'),
          ),
          body: Column(
            children: [
              AddTodo(),
              TodoList(),
            ],
          ),
          floatingActionButton: AnimatedFAB(
            onPressed: provider.hasText ? _addTodo : _toggleAddTodo,
            child: provider.hasText ? const Icon(Icons.done) : const Icon(Icons.add),
            backgroundColor: provider.hasText ? Colors.green : Colors.blue,
          ),
        );
      },
    );
  }
}
