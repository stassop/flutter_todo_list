import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/widgets/error_dialog.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    Key? key
  }) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  void initState() {
    super.initState();
    Provider.of<TodoListProvider>(context, listen: false)
      .getTodos(_onError);
  }

  void _onError(String error) {
    ErrorDialog.show(context, error);
  }

  void _toggleTodo(int id, bool isDone) {
    Provider.of<TodoListProvider>(context, listen: false)
      .toggleTodo(id, isDone, _onError);
  }

  void _deleteTodo(int id) {
    Provider.of<TodoListProvider>(context, listen: false)
      .deleteTodo(id, _onError);
  }

  List<Widget> _buildTiles(List<Todo> todos) {
    final doneTextStyle = const TextStyle(
      decoration: TextDecoration.lineThrough,
    );

    final tiles = todos.map((Todo todo) {
      final int index = todos.indexOf(todo);
      return Dismissible(
        key: Key('$todo$index'), // required
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) => _deleteTodo(todo.id),
        child: CheckboxListTile(
          title: Text(
            todo.text,
            style: todo.isDone ? doneTextStyle : null,
          ),
          value: todo.isDone,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) => _toggleTodo(todo.id, value ?? false),
        ),
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:  EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
      );
    });
    return ListTile.divideTiles(context: context, tiles: tiles).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded( // accommodate for list dimensions overflow
      child: Consumer<TodoListProvider>(
        builder: (BuildContext context, TodoListProvider provider, Widget? child) {
          if (provider.todos.isNotEmpty) {
            final List<Widget> tiles = _buildTiles(provider.todos);
            return ListView(children: tiles);
          } else if (provider.isBusy) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text('Todo List is empty'),
            );
          }
        },
      ),
    );
  }
}
