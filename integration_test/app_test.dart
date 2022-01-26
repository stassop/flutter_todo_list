import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_todo_list/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App end-to-end test', () {
    testWidgets('Should add, check, and delete todos', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add todo
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Another todo');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.done));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(CheckboxListTile, 'Another todo'), findsOneWidget); // added

      // Check todo
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Another todo'));
      await tester.pumpAndSettle();

      expect(tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Another todo'),
          matching: find.byType(CheckboxListTile),
        )
      ).value, true); // checked

      // Delete todo
      await tester.drag(
        find.ancestor(
          of: find.text('Another todo'),
          matching: find.byType(Dismissible),
        ), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(CheckboxListTile, 'Another todo'), findsNothing); // deleted
    });
  });
}
