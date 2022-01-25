import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/widgets/add_todo.dart';
import 'package:flutter_todo_list/widgets/todo_list.dart';
import 'package:flutter_todo_list/widgets/stateful_fab.dart';

import 'package:flutter_todo_list/providers/add_todo_provider.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AddTodoProvider()),
        ChangeNotifierProvider(create: (context) => TodoListProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo List'),
        ),
        body: Column(
          children: [
            AddTodo<AddTodoProvider>(),
            Expanded(
              child: TodoList<TodoListProvider>()
            ),
          ],
        ),
        floatingActionButton: StatefulFAB<AddTodoProvider, TodoListProvider>(),
      ),
    );
  }
}
