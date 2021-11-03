import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/todo_list_provider.dart';
import 'package:flutter_todo_list/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: ChangeNotifierProvider(
        create: (context) => TodoListProvider(),
        child: HomePage(),
      ),
    );
  }
}
