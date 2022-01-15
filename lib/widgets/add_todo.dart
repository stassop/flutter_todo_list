import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/providers/add_todo_provider.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final String sanitizedText = _controller.text.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
      final AddTodoProvider provider = Provider.of<AddTodoProvider>(context, listen: false);
      if (provider.text != sanitizedText) {
        provider.text = sanitizedText;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    Provider.of<AddTodoProvider>(context, listen: false).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddTodoProvider>(
      builder: (BuildContext context, AddTodoProvider provider, Widget? child) {
        // update text if it's changed
        if (_controller.text != provider.text) {
          _controller.text = provider.text;
        }
        return AddTodoTransition(
          isVisible: provider.isVisible,
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'New todo',
                suffixIcon: provider.hasText
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clear,
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
