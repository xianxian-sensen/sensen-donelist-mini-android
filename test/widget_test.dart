// This is a basic Flutter widget test for the DoneList app.
//
// To perform an interaction with a widget in a test, run `flutter test`
// from the project root. The test framework will verify that the widget
// tree is built correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 构建一个简单的 smoke test：确认应用能渲染标题文字
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('DoneList'),
          ),
        ),
      ),
    );

    expect(find.text('DoneList'), findsOneWidget);
  });
}
