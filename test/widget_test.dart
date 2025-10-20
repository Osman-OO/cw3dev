import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/main.dart';

void main() {
  testWidgets('Task Manager app loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('App displays empty state message', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet. Add one to get started!'), findsOneWidget);
  });

  testWidgets('UI elements are present', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('Statistics cards are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });
}
