import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_todo_list/widgets/todo_list.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

import 'todo_list_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// To generate mocks run `flutter pub run build_runner build`
@GenerateMocks([BuildContext, TodoListProvider])
void main() {
  group('TodoList', () {
    testWidgets('Should show a progress indicator when busy', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockTodoListProvider();

      when(provider.todos).thenReturn([]);
      when(provider.isBusy).thenReturn(true);
      when(provider.getTodos(onError: anyNamed('onError'))).thenAnswer((_) async => null); // stub

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: TodoList<MockTodoListProvider>(),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should show a message when empty', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockTodoListProvider();

      when(provider.todos).thenReturn([]);
      when(provider.isBusy).thenReturn(false);
      when(provider.getTodos(onError: anyNamed('onError'))).thenAnswer((_) async => null); // stub

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: TodoList<MockTodoListProvider>(),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsNothing);
      expect(find.text('Todo list is empty'), findsOneWidget);
    });

    testWidgets('Should show todos when not empty', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockTodoListProvider();
      final todo = const Todo(id: 1, text: 'Another todo', isDone: false);

      when(provider.todos).thenReturn(<Todo>[todo]);
      when(provider.isBusy).thenReturn(false);
      when(provider.getTodos(onError: anyNamed('onError'))).thenAnswer((_) async => null); // stub

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: TodoList<MockTodoListProvider>(),
            ),
          ),
        ),
      );

      expect(find.descendant(
        of: find.byType(ListView),
        matching: find.widgetWithText(CheckboxListTile, 'Another todo')
      ), findsOneWidget);
    });

    testWidgets('Should handle toggle and delete actions', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockTodoListProvider();
      final todo = const Todo(id: 1, text: 'Another todo', isDone: false);

      when(provider.todos).thenReturn(<Todo>[todo]);
      when(provider.isBusy).thenReturn(false);
      when(provider.getTodos(onError: anyNamed('onError'))).thenAnswer((_) async => null); // stub

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: TodoList<MockTodoListProvider>(),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Another todo'));
      await tester.pump(); // rebuild the widget with the new item

      verify(provider.toggleTodo(1, true, onError: anyNamed('onError'))).called(1);

      await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle(); // build the widget until the dismiss animation ends

      verify(provider.deleteTodo(1, onError: anyNamed('onError'))).called(1);
    });
  });
}
