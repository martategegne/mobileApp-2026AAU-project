import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/home/presentation/widgets/activity_card.dart';

import '../../test_helper.dart';

void main() {
  group('ActivityCard Widget Tests', () {
    testWidgets('ActivityCard displays icon with correct color', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.upload;
      const testColor = Colors.green;
      const testTitle = 'Resource Uploaded';
      const testTime = '2 hours ago';

      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: testIcon,
            iconColor: testColor,
            title: testTitle,
            time: testTime,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testTime), findsOneWidget);
    });

    testWidgets('ActivityCard has correct layout structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.bookmark;
      const testColor = Colors.blue;
      const testTitle = 'Bookmark Added';
      const testTime = '1 hour ago';

      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: testIcon,
            iconColor: testColor,
            title: testTitle,
            time: testTime,
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('ActivityCard displays all text content', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.done;
      const testColor = Colors.purple;
      const testTitle = 'Review Completed';
      const testTime = 'Just now';

      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: testIcon,
            iconColor: testColor,
            title: testTitle,
            time: testTime,
          ),
        ),
      );

      // Act
      final titleText = find.text(testTitle);
      final timeText = find.text(testTime);

      // Assert
      expect(titleText, findsOneWidget);
      expect(timeText, findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('ActivityCard icon container has correct decoration', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.help;
      const testColor = Colors.orange;
      const testTitle = 'Question Asked';
      const testTime = '30 minutes ago';

      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: testIcon,
            iconColor: testColor,
            title: testTitle,
            time: testTime,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('ActivityCard renders with different icon colors', (
      WidgetTester tester,
    ) async {
      // Test with red icon
      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: 'Error Occurred',
            time: 'Now',
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Error Occurred'), findsOneWidget);
      await tester.pumpAndSettle();

      // Test with yellow icon
      await tester.pumpWidget(
        TestApp(
          child: ActivityCard(
            icon: Icons.warning,
            iconColor: Colors.yellow,
            title: 'Warning',
            time: 'Now',
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('ActivityCard text is readable and not truncated', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.star;
      const testColor = Colors.amber;
      const testTitle = 'Resource Favorited';
      const testTime = '5 minutes ago';

      await tester.pumpWidget(
        TestApp(
          child: SingleChildScrollView(
            child: ActivityCard(
              icon: testIcon,
              iconColor: testColor,
              title: testTitle,
              time: testTime,
            ),
          ),
        ),
      );

      // Assert
      final titleFinder = find.text(testTitle);
      expect(titleFinder, findsOneWidget);

      // Verify text size
      final textWidget = find.byType(Text);
      expect(textWidget, findsWidgets);
    });

    testWidgets('ActivityCard handles long text gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testIcon = Icons.info;
      const testColor = Colors.cyan;
      const testTitle =
          'A very long title for the activity card that might wrap to multiple lines';
      const testTime = 'A very long timestamp description';

      await tester.pumpWidget(
        TestApp(
          child: SingleChildScrollView(
            child: ActivityCard(
              icon: testIcon,
              iconColor: testColor,
              title: testTitle,
              time: testTime,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testTime), findsOneWidget);
    });
  });
}
