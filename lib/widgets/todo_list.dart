import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    Provider.of<TodoListProvider>(context, listen: false).fetchTodos(onError: showError);
  }

  void showError(String? error) {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _doneTextStyle = const TextStyle(
    color: Colors.grey,
    decoration: TextDecoration.lineThrough,
  );

  void _toggleTodo(int id) {
    Provider.of<TodoListProvider>(context, listen: false).toggleTodo(id: id, onError: showError);
  }

  void _deleteTodo(int id) {
    Provider.of<TodoListProvider>(context, listen: false).deleteTodo(id: id, onError: showError);
  }

  List<Widget> _buildTiles(List<Todo> todos) {
    final tiles = todos.map((Todo todo) {
      final int index = todos.indexOf(todo);
      final bool isDone = todo.isDone;
      return Dismissible(
        key: Key('$todo$index'), // required
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) => _deleteTodo(todo.id),
        child: ListTile(
          title: Text(
            todo.text,
            style: isDone ? _doneTextStyle : null,
          ),
          leading: IconButton(
            icon: Icon(isDone ? Icons.check_box : Icons.check_box_outline_blank),
            color: isDone ? Colors.blue : Colors.grey,
            onPressed: () => _toggleTodo(todo.id),
          ),
        ),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
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
            final tiles = _buildTiles(provider.todos);
            return ListView(children: tiles);
          } else if (provider.isBusy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text('Todo List is empty'),
            );
          }
        },
      ),
    );
  }
}
