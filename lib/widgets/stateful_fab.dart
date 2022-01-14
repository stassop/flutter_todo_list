import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/widgets/animated_fab.dart';

import 'package:flutter_todo_list/providers/add_todo_provider.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

class StatefulFab extends StatefulWidget {
  const StatefulFab({Key? key}) : super(key: key);

  @override
  State<StatefulFab> createState() => _StatefulFabState();
}

class _StatefulFabState extends State<StatefulFab> {
  void _addTodo(String text) {
    Provider.of<TodoListProvider>(context, listen: false)
      .addTodo(text: text, onSuccess: _onAddTodoSuccess, onError: _showError);
  }

  void _onAddTodoSuccess() {
    Provider.of<AddTodoProvider>(context, listen: false).clear();
  }

  void _toggleAddTodo() {
    Provider.of<AddTodoProvider>(context, listen: false).toggle();
  }

  void _showError(String error) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oops!'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
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
    return Consumer<AddTodoProvider>(
      builder: (BuildContext context, AddTodoProvider provider, Widget? child) {
        return AnimatedFAB(
          onPressed: provider.hasText ? () => _addTodo(provider.text) : _toggleAddTodo,
          child: provider.hasText ? const Icon(Icons.done) : const Icon(Icons.add),
          backgroundColor: provider.hasText ? Colors.green : Colors.blue,
        );
      },
    );
  }
}
