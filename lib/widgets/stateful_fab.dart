import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/widgets/animated_fab.dart';
import 'package:flutter_todo_list/widgets/error_dialog.dart';
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
      .addTodo(text, onSuccess: _onAddTodoSuccess, onError: _onAddTodoError);
  }

  void _onAddTodoSuccess() {
    Provider.of<AddTodoProvider>(context, listen: false).clear();
  }

  void _onAddTodoError(String error) {
    ErrorDialog.show(context, error);
  }

  void _toggleAddTodo() {
    Provider.of<AddTodoProvider>(context, listen: false).toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddTodoProvider>(
      builder: (BuildContext context, AddTodoProvider provider, Widget? child) {
        final Icon icon;
        if (provider.hasText) {
          icon = const Icon(Icons.done);
        } else if (provider.isVisible) {
          icon = const Icon(Icons.close);
        } else {
          icon = const Icon(Icons.add);
        }

        void onPressed() {
          if (provider.hasText) {
            _addTodo(provider.text);
          } else {
            _toggleAddTodo();
          }
        }

        return AnimatedFAB(
          onPressed: onPressed,
          child: icon,
          backgroundColor: provider.hasText ? Colors.green : Colors.blue,
        );
      },
    );
  }
}
