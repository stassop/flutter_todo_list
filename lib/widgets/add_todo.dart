import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/providers/add_todo_provider.dart';

class AddTodo<T extends AddTodoProvider> extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState<T>();
}

class _AddTodoState<T extends AddTodoProvider> extends State<AddTodo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final String sanitizedText = _sanitizeText(_controller.text);
      final T provider = context.read<T>();
      if (provider.text != sanitizedText) { // avoid circular logic
        provider.text = sanitizedText;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
  }

  void _clear() {
    _controller.clear();
    context.read<T>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final T provider = context.watch<T>();

    if (_controller.text != provider.text) { // avoid circular logic
      _controller.text = provider.text;
    }

    return ClipRect(
      child: AnimatedAlign(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 200),
        heightFactor: provider.isVisible ? 1 : 0,
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
          child: TextField(
            autofocus: true,
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'New todo',
              suffixIcon: provider.hasText
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  )
                : null,
            ),
          ),
        ),
      )
    );
  }
}
