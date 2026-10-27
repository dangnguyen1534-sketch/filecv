
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ConnectAI basic widget test', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('ConnectAI'),
          ),
        ),
      ),
    );

    expect(find.text('ConnectAI'), findsOneWidget);
  });
}
