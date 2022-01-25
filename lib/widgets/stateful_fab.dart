import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/widgets/animated_fab.dart';
import 'package:flutter_todo_list/widgets/error_dialog.dart';
import 'package:flutter_todo_list/providers/add_todo_provider.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

class StatefulFAB<T extends AddTodoProvider, U extends TodoListProvider> extends StatefulWidget {
  const StatefulFAB({Key? key}) : super(key: key);

  @override
  State<StatefulFAB> createState() => _StatefulFABState<T, U>();
}

class _StatefulFABState<T extends AddTodoProvider, U extends TodoListProvider> extends State<StatefulFAB> {
  void _addTodo(String text) {
    context.read<U>().addTodo(text, onSuccess: _onAddTodoSuccess, onError: _onAddTodoError);
  }

  void _onAddTodoSuccess() {
    context.read<T>().clear();
  }

  void _onAddTodoError(String error) {
    ErrorDialog.show(context, error);
  }

  void _toggleAddTodo() {
    context.read<T>().toggle();
  }

  @override
  Widget build(BuildContext context) {
    final T provider = context.watch<T>();

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
  }
}
