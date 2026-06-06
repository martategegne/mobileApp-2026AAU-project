import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/home/presentation/widgets/quick_action_grid.dart';

import '../../test_helper.dart';

void main() {
  group('QuickActionGrid Widget Tests', () {
    late bool uploadTapped;
    late bool requestTapped;
    late bool bookmarksTapped;
    late bool secondaryTapped;

    setUp(() {
      uploadTapped = false;
      requestTapped = false;
      bookmarksTapped = false;
      secondaryTapped = false;
    });

    testWidgets('QuickActionGrid displays all action cards for student',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('QuickActionGrid displays correct cards for admin',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: true,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Rate & Review'), findsOneWidget);
      expect(find.text('Downloads'), findsNothing);
    });

    testWidgets('QuickActionGrid upload button is tappable',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();

      // Assert
      expect(uploadTapped, isTrue);
      expect(requestTapped, isFalse);
      expect(bookmarksTapped, isFalse);
      expect(secondaryTapped, isFalse);
    });

    testWidgets('QuickActionGrid request button is tappable',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();

      // Assert
      expect(requestTapped, isTrue);
      expect(uploadTapped, isFalse);
      expect(bookmarksTapped, isFalse);
      expect(secondaryTapped, isFalse);
    });

    testWidgets('QuickActionGrid bookmarks button is tappable',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Bookmarks'));
      await tester.pumpAndSettle();

      // Assert
      expect(bookmarksTapped, isTrue);
      expect(uploadTapped, isFalse);
      expect(requestTapped, isFalse);
      expect(secondaryTapped, isFalse);
    });

    testWidgets('QuickActionGrid secondary button executes correct callback',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Downloads'));
      await tester.pumpAndSettle();

      // Assert
      expect(secondaryTapped, isTrue);
      expect(uploadTapped, isFalse);
      expect(requestTapped, isFalse);
      expect(bookmarksTapped, isFalse);
    });

    testWidgets(
        'QuickActionGrid secondary admin button executes correct callback',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: true,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Rate & Review'));
      await tester.pumpAndSettle();

      // Assert
      expect(secondaryTapped, isTrue);
      expect(uploadTapped, isFalse);
      expect(requestTapped, isFalse);
      expect(bookmarksTapped, isFalse);
    });

    testWidgets('QuickActionGrid displays all subtitles correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Share resources'), findsOneWidget);
      expect(find.text('Ask for materials'), findsOneWidget);
      expect(find.text('Saved resources'), findsOneWidget);
      expect(find.text('Fetch downloads'), findsOneWidget);
    });

    testWidgets('QuickActionGrid displays correct admin subtitles',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: true,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Share resources'), findsOneWidget);
      expect(find.text('Ask for materials'), findsOneWidget);
      expect(find.text('Saved resources'), findsOneWidget);
      expect(find.text('Feedback on resources'), findsOneWidget);
    });

    testWidgets('QuickActionGrid displays all icons', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
      expect(find.byIcon(Icons.download_for_offline_outlined), findsOneWidget);
    });

    testWidgets('QuickActionGrid displays correct admin icon',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: true,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('QuickActionGrid has correct grid layout', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadTapped = true,
            onRequest: () => requestTapped = true,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Assert
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      // Verify grid has 4 children (cards)
      expect(find.byType(GestureDetector), findsNWidgets(4));
    });

    testWidgets('QuickActionGrid cards are properly spaced', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SingleChildScrollView(
            child: QuickActionGrid(
              isAdmin: false,
              onUpload: () => uploadTapped = true,
              onRequest: () => requestTapped = true,
              onBookmarks: () => bookmarksTapped = true,
              onSecondary: () => secondaryTapped = true,
            ),
          ),
        ),
      );

      // Assert - Verify all cards are rendered
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('QuickActionGrid multiple taps work correctly',
        (WidgetTester tester) async {
      // Arrange
      int uploadCount = 0;
      int requestCount = 0;

      await tester.pumpWidget(
        TestApp(
          child: QuickActionGrid(
            isAdmin: false,
            onUpload: () => uploadCount++,
            onRequest: () => requestCount++,
            onBookmarks: () => bookmarksTapped = true,
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();

      // Assert
      expect(uploadCount, equals(2));
      expect(requestCount, equals(1));
    });
  });
}
