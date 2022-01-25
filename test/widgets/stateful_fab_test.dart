import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_todo_list/widgets/stateful_fab.dart';
import 'package:flutter_todo_list/providers/add_todo_provider.dart';
import 'package:flutter_todo_list/providers/todo_list_provider.dart';

import 'stateful_fab_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// To generate mocks run `flutter pub run build_runner build`
@GenerateMocks([BuildContext, AddTodoProvider, TodoListProvider])
void main() {
  testWidgets('Should show an add icon and handle clicks', (WidgetTester tester) async {
    final context = MockBuildContext();
    final provider = MockAddTodoProvider();

    when(provider.hasText).thenReturn(false);
    when(provider.isVisible).thenReturn(false);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => provider,
        child: MaterialApp( // required for widgets to render correctly
          home: Scaffold(
            body: StatefulFAB<MockAddTodoProvider, MockTodoListProvider>(),
          ),
        ),
      ),
    );

    expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);

    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pump(); // rebuild the widget with the new item

    verify(provider.toggle()).called(1);
  });

  testWidgets('Should show a close icon and handle clicks', (WidgetTester tester) async {
    final context = MockBuildContext();
    final provider = MockAddTodoProvider();

    when(provider.hasText).thenReturn(false);
    when(provider.isVisible).thenReturn(true);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => provider,
        child: MaterialApp( // required for widgets to render correctly
          home: Scaffold(
            body: StatefulFAB<MockAddTodoProvider, MockTodoListProvider>(),
          ),
        ),
      ),
    );

    expect(find.widgetWithIcon(FloatingActionButton, Icons.close), findsOneWidget);

    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.close));
    await tester.pump(); // rebuild the widget with the new item

    verify(provider.toggle()).called(1);
  });

  testWidgets('Should show a done icon and handle clicks', (WidgetTester tester) async {
    final context = MockBuildContext();
    final addTodoProvider = MockAddTodoProvider();
    final todoListProvider = MockTodoListProvider();

    when(addTodoProvider.text).thenReturn('Another todo');
    when(addTodoProvider.hasText).thenReturn(true);
    when(addTodoProvider.isVisible).thenReturn(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => addTodoProvider),
          ChangeNotifierProvider(create: (context) => todoListProvider),
        ],
        child: MaterialApp( // required for widgets to render correctly
          home: Scaffold(
            body: StatefulFAB<MockAddTodoProvider, MockTodoListProvider>(),
          ),
        ),
      ),
    );

    expect(find.widgetWithIcon(FloatingActionButton, Icons.done), findsOneWidget);

    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.done));
    await tester.pump(); // rebuild the widget with the new item

    verify(todoListProvider.addTodo(
      'Another todo',
      onSuccess: anyNamed('onSuccess'), // stub
      onError: anyNamed('onError'), // stub
    )).called(1);
  });
}
