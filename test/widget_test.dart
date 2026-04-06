// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:go_grabit/main.dart';

void main() {
  testWidgets('After splash screen, Home screen is displayed with content', (
    WidgetTester tester,
  ) async {
    // Arrange: Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Act: Wait for the splash screen animation to complete.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Assert: Verify the home screen is shown with expected content.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
  });
}
