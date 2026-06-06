import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Test helper widget for wrapping widgets in test environment
/// Provides ProviderScope for Riverpod state management
class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
        theme: theme ?? ThemeData.light(),
        darkTheme: theme ?? ThemeData.dark(),
      ),
    );
  }
}

/// Extended test app with router support for navigation tests
class TestAppWithRouter extends StatelessWidget {
  final GoRouter router;
  final ThemeData? theme;

  const TestAppWithRouter({
    super.key,
    required this.router,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: theme ?? ThemeData.light(),
        darkTheme: theme ?? ThemeData.dark(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Helper extension for common widget test operations
extension WidgetTesterHelper on WidgetTester {
  /// Pump widget and settle all animations
  Future<void> pumpWidget(Widget widget) async {
    await this.pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pump widget with custom duration for animations
  Future<void> pumpWidgetWithDuration(
    Widget widget, {
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await this.pumpWidget(widget);
    await pumpAndSettle(duration);
  }

  /// Find and tap widget by text
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pumpAndSettle();
  }

  /// Find and tap widget by icon
  Future<void> tapByIcon(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }

  /// Enter text into a text field by key
  Future<void> enterTextByKey(String key, String text) async {
    await enterText(find.byKey(Key(key)), text);
    await pumpAndSettle();
  }

  /// Check if widget with text exists
  bool hasText(String text) {
    return find.text(text).evaluate().isNotEmpty;
  }

  /// Check if widget by type exists
  bool hasWidget<T extends Widget>() {
    return find.byType(T).evaluate().isNotEmpty;
  }

  /// Get text from widget
  String? getTextFromWidget(Finder finder) {
    final element = finder.evaluate().firstOrNull;
    if (element == null) return null;

    final widget = element.widget;
    if (widget is Text) {
      return widget.data;
    }
    return null;
  }
}

/// Custom finder extensions for more readable tests
extension CustomFinders on CommonFinders {
  /// Find button by label text
  Finder buttonWithLabel(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(GestureDetector),
    );
  }

  /// Find icon button
  Finder iconButton(IconData icon) {
    return find.byWidgetPredicate((widget) {
      if (widget is IconButton) {
        return widget.icon is Icon && (widget.icon as Icon).icon == icon;
      }
      return false;
    });
  }
}

/// Mock data generators for testing
class MockDataGenerator {
  static const String mockUserName = 'John Doe';
  static const String mockUserEmail = 'john@example.com';
  static const String mockUserRole = 'student';

  static const String mockResourceTitle = 'Flutter Basics';
  static const String mockResourceDescription =
      'Learn the basics of Flutter development';

  static const String mockBookmarkTitle = 'Advanced Flutter';
  static const String mockBookmarkDescription =
      'Advanced topics in Flutter development';

  static const String mockActivityTitle = 'Uploaded Flutter Guide';
  static const String mockActivityTime = '2 hours ago';

  static const String mockEmptyMessage = 'No items found';
  static const String mockErrorMessage = 'An error occurred';
  static const String mockLoadingMessage = 'Loading...';
}

/// Test scenario builder for common test patterns
class TestScenario {
  final WidgetTester tester;

  TestScenario(this.tester);

  /// Scroll to find widget
  Future<void> scrollUntilVisible(
    Finder finder, {
    double scrollDelta = -300,
    int maxScrolls = 5,
  }) async {
    int scrollCount = 0;
    while (scrollCount < maxScrolls) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.scrollUntilVisible(finder, scrollDelta);
      await tester.pumpAndSettle();
      scrollCount++;
    }
  }

  /// Verify error state display
  Future<void> verifyErrorState(String errorMessage) async {
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  /// Verify loading state display
  Future<void> verifyLoadingState() async {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verify empty state display
  Future<void> verifyEmptyState(String emptyMessage) async {
    expect(find.text(emptyMessage), findsOneWidget);
  }

  /// Verify list item count
  Future<void> verifyListItemCount(int count) async {
    expect(find.byType(ListTile), findsNWidgets(count));
  }
}
