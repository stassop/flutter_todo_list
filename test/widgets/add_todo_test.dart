import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_todo_list/widgets/add_todo.dart';
import 'package:flutter_todo_list/providers/add_todo_provider.dart';

import 'add_todo_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// To generate mocks run `flutter pub run build_runner build`
@GenerateMocks([BuildContext, AddTodoProvider])
void main() {
  group('AddTodo', () {
    testWidgets('Should show collpased state', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockAddTodoProvider();

      when(provider.text).thenReturn('');
      when(provider.hasText).thenReturn(false);
      when(provider.isVisible).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: AddTodo<MockAddTodoProvider>(),
            ),
          ),
        ),
      );

      expect(tester.widget<AnimatedAlign>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(AnimatedAlign),
        )
      ).heightFactor, 0); // is collapsed
    });

    testWidgets('Should show open state', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockAddTodoProvider();

      when(provider.text).thenReturn('');
      when(provider.hasText).thenReturn(false);
      when(provider.isVisible).thenReturn(true);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: AddTodo<MockAddTodoProvider>(),
            ),
          ),
        ),
      );

      expect(tester.widget<AnimatedAlign>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(AnimatedAlign),
        )
      ).heightFactor, 1); // is open
    });

    testWidgets('Should handle text clearing', (WidgetTester tester) async {
      final context = MockBuildContext();
      final provider = MockAddTodoProvider();

      when(provider.text).thenReturn('Another todo');
      when(provider.hasText).thenReturn(true);
      when(provider.isVisible).thenReturn(true);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => provider,
          child: MaterialApp( // required for widgets to render correctly
            home: Scaffold(
              body: AddTodo<MockAddTodoProvider>(),
            ),
          ),
        ),
      );

      expect(find.widgetWithText(TextField, 'Another todo'), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.clear), findsOneWidget);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.clear));
      await tester.pump(); // rebuild the widget with the new item

      verify(provider.clear()).called(1);
    });
  });
}
