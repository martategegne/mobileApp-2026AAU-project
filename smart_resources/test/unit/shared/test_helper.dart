import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test helpers for all test files
class TestHelper {
  /// Wait for a widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpWidget(SizedBox.shrink());
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Tap a button and wait for navigation
  static Future<void> tapAndNavigate(
    WidgetTester tester,
    Finder finder, {
    Duration delay = const Duration(seconds: 2),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(delay);
  }

  /// Enter text into a field
  static Future<void> enterTextIntoField(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Fill in a form with provided data
  static Future<void> fillForm(
    WidgetTester tester,
    Map<Key, String> fieldValues,
  ) async {
    fieldValues.forEach((key, value) async {
      await enterTextIntoField(tester, find.byKey(key), value);
    });
  }

  /// Verify widget is present
  static void verifyWidget(Finder finder, {bool present = true}) {
    if (present) {
      expect(finder, findsOneWidget);
    } else {
      expect(finder, findsNothing);
    }
  }

  /// Scroll to widget
  static Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  /// Verify text appears on screen
  static void verifyText(String text, {bool present = true}) {
    if (present) {
      expect(find.text(text), findsOneWidget);
    } else {
      expect(find.text(text), findsNothing);
    }
  }

  /// Wait for any pending async operations
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Verify loading indicator
  static void verifyLoading(bool isLoading) {
    if (isLoading) {
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    } else {
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
  }
}
