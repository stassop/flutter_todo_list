import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/todo_list_provider.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class AddTodoTransition extends StatelessWidget {
  const AddTodoTransition({
    Key? key,
    required this.child,
    required this.isVisible,
  }) : super(key: key);

  final Widget child;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
      child: AnimatedSize(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 500),
        child: Visibility(
          visible: isVisible,
          child: child,
        ),
      ),
    );
  }
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textFieldController.addListener(() {
      final TodoListProvider provider = Provider.of<TodoListProvider>(context, listen: false);
      if (provider.text != _textFieldController.text) {
        provider.text = _textFieldController.text;
      }
    });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _clearTextField() {
    _textFieldController.clear();
    Provider.of<TodoListProvider>(context, listen: false).clearText();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListProvider>(
      builder: (context, provider, child) {
        if (_textFieldController.text != provider.text) {
          _textFieldController.text = provider.text;
        }
        return AddTodoTransition(
          isVisible: provider.isAddTodoVisible,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: TextField(
              maxLength: 100,
              autofocus: true,
              controller: _textFieldController,
              decoration: InputDecoration(
                labelText: 'New todo',
                suffixIcon: provider.hasText
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clearTextField,
                    )
                  : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
