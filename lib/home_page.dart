import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/add_todo.dart';
import 'package:flutter_todo_list/todo_list.dart';
import 'package:flutter_todo_list/todo_list_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  initState() {
    super.initState();
  }

  void _addTodo() {
    Provider.of<TodoListProvider>(context, listen: false).addTodo();
  }

  void _toggleAddTodo() {
    Provider.of<TodoListProvider>(context, listen: false).toggleAddTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListProvider>(
      builder: (context, provider, child) {
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
          floatingActionButton: FloatingActionButton(
            child: provider.hasText ? Icon(Icons.done) : Icon(Icons.add),
            onPressed: provider.hasText ? _addTodo : _toggleAddTodo,
            backgroundColor: provider.hasText ? Colors.green : Colors.blue,
          ),
        );
      },
    );
  }
}
