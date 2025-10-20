import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/main.dart';

void main() {
  testWidgets('Task Manager app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('No tasks yet. Add one to get started!'), findsOneWidget);
  });

  testWidgets('Add task functionality', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    await tester.enterText(find.byType(TextField), 'Test Task');
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);
  });

  testWidgets('Toggle task completion', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    await tester.enterText(find.byType(TextField), 'Test Task');
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);
  });
}
