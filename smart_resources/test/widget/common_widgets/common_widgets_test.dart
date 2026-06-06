import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

/// Loading indicator widget for testing
class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

/// Error widget for testing
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom button widget for testing
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final ButtonStyle? style;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: Text(label),
    );
  }
}

/// Custom card widget for testing
class CustomCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rating widget for testing
class RatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;

  const RatingWidget({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index < currentRating;
        return GestureDetector(
          onTap: () {
            setState(() {
              currentRating = index + 1;
            });
            widget.onRatingChanged(currentRating);
          },
          child: Icon(
            isFilled ? Icons.star : Icons.star_outline,
            color: isFilled ? Colors.amber : Colors.grey,
            size: 32,
          ),
        );
      }),
    );
  }
}

void main() {
  group('Common Widgets Tests', () {
    testWidgets('Loading indicator should display', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const TestApp(
          child: LoadingIndicator(),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('Loading indicator displays custom message', (
      WidgetTester tester,
    ) async {
      // Arrange
      const customMessage = 'Please wait...';

      await tester.pumpWidget(
        const TestApp(
          child: LoadingIndicator(message: customMessage),
        ),
      );

      // Assert
      expect(find.text(customMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Error widget should display error message', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Something went wrong';

      await tester.pumpWidget(
        TestApp(
          child: ErrorDisplay(
            message: errorMessage,
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Error widget displays retry button', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool retryPressed = false;

      await tester.pumpWidget(
        TestApp(
          child: ErrorDisplay(
            message: 'An error occurred',
            onRetry: () => retryPressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      expect(retryPressed, isTrue);
    });

    testWidgets('Error widget without retry button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const TestApp(
          child: ErrorDisplay(
            message: 'An error occurred',
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('Custom button should be clickable', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool clicked = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(
              child: CustomButton(
                label: 'Click Me',
                onPressed: () => clicked = true,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      // Assert
      expect(clicked, isTrue);
    });

    testWidgets('Custom button can be disabled', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool clicked = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(
              child: CustomButton(
                label: 'Disabled Button',
                enabled: false,
                onPressed: () => clicked = true,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Disabled Button'));
      await tester.pumpAndSettle();

      // Assert
      expect(clicked, isFalse);
    });

    testWidgets('Custom card widget should render correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: CustomCard(
              title: 'Test Card',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('Custom card with description', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: CustomCard(
              title: 'Card Title',
              subtitle: 'Subtitle',
              description: 'Card Description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Card Description'), findsOneWidget);
    });

    testWidgets('Custom card is tappable', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool cardTapped = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: CustomCard(
              title: 'Tappable Card',
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Assert
      expect(cardTapped, isTrue);
    });

    testWidgets('Rating widget should be interactive', (
      WidgetTester tester,
    ) async {
      // Arrange
      int rating = 0;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: RatingWidget(
              onRatingChanged: (value) => rating = value,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.star_outline).at(4));
      await tester.pumpAndSettle();

      // Assert
      expect(rating, equals(5));
    });

    testWidgets('Rating widget with initial rating', (
      WidgetTester tester,
    ) async {
      // Arrange
      int rating = 0;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: RatingWidget(
              initialRating: 3,
              onRatingChanged: (value) => rating = value,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('Rating widget partial rating', (
      WidgetTester tester,
    ) async {
      // Arrange
      int rating = 0;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: RatingWidget(
              onRatingChanged: (value) => rating = value,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.star_outline).at(2));
      await tester.pumpAndSettle();

      // Assert
      expect(rating, equals(3));
    });

    testWidgets('Rating widget changes rating on tap', (
      WidgetTester tester,
    ) async {
      // Arrange
      int rating = 0;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: RatingWidget(
              onRatingChanged: (value) => rating = value,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.star_outline).at(1));
      await tester.pumpAndSettle();

      // Assert
      expect(rating, equals(2));
    });

    testWidgets('Custom button multiple taps', (
      WidgetTester tester,
    ) async {
      // Arrange
      int tapCount = 0;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(
              child: CustomButton(
                label: 'Tap Multiple',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Tap Multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap Multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap Multiple'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapCount, equals(3));
    });

    testWidgets('Loading indicator centers content', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const TestApp(
          child: LoadingIndicator(message: 'Loading content'),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Error widget centers content', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const TestApp(
          child: ErrorDisplay(message: 'Error loading'),
        ),
      );

      // Assert
      expect(find.text('Error loading'), findsOneWidget);
    });

    testWidgets('Custom card displays all optional fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: CustomCard(
              title: 'Full Card',
              subtitle: 'With subtitle',
              description: 'And description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Full Card'), findsOneWidget);
      expect(find.text('With subtitle'), findsOneWidget);
      expect(find.text('And description'), findsOneWidget);
    });
  });
}
