// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logs_mobile_app/main.dart';

void main() {
  testWidgets('LogsApp displays welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const LogsApp());

    expect(find.text('Welcome to Logs App!'), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('LogsApp uses indigo as primary color',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LogsApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    final ThemeData theme = app.theme!;
    expect(theme.primaryColor, Colors.indigo);
  });

  testWidgets('LogsApp does not show debug banner',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LogsApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
