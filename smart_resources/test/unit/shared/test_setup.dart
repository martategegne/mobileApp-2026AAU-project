// Test configuration and setup
// This file provides common setup for all tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test setup
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set device size for consistent testing
  addTearDown(
    TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue,
  );
}

/// Create a test widget that wraps your app for testing
MaterialApp createTestApp({
  required Widget home,
  Map<String, WidgetBuilder>? routes,
  NavigatorObserver? navigatorObserver,
}) {
  return MaterialApp(
    home: home,
    routes: routes ?? {},
    navigatorObservers: [if (navigatorObserver != null) navigatorObserver],
    theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
  );
}

/// Mock navigator observer for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}

/// Wait for a given duration
Future<void> delay(Duration duration) async {
  await Future.delayed(duration);
}

/// Pump widget and wait for animations to complete
Future<void> pumpAndWait(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Get all text widgets on screen
List<Text> getAllText(WidgetTester tester) {
  final textWidgets = find.byType(Text).evaluate().cast<Element>();
  return textWidgets.map((e) => e.widget as Text).toList();
}

/// Verify specific error message appears
void expectErrorMessage(String message) {
  expect(find.text(message), findsOneWidget);
}

/// Verify specific success message appears
void expectSuccessMessage(String message) {
  expect(find.text(message), findsOneWidget);
}

/// Check if a widget is visible
bool isWidgetVisible(WidgetTester tester, Finder finder) {
  try {
    return finder.evaluate().isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// Scroll ListView to bottom
Future<void> scrollListViewToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -500));
  await tester.pumpAndSettle();
}

/// Scroll ListView to top
Future<void> scrollListViewToTop(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, 500));
  await tester.pumpAndSettle();
}

/// Dismiss all dialogs
Future<void> dismissAllDialogs(WidgetTester tester) async {
  while (find.byType(AlertDialog).evaluate().isNotEmpty) {
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
  }
}

/// Get text from widget
String getWidgetText(WidgetTester tester, Finder finder) {
  final text =
      find.byWidget(tester.widget(finder)).evaluate().first.widget as Text;
  return text.data ?? '';
}
