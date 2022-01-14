import 'package:flutter/foundation.dart';

class AddTodoProvider extends ChangeNotifier {
  String _text = '';
  bool isVisible = false;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

  String get text => _text;

  bool get hasText => _text.length > 0;

  void clear() {
    _text = '';
    notifyListeners();
  }

  void toggle() {
    isVisible = !isVisible;
    notifyListeners();
  }
}
