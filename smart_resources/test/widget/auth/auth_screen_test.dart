import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_resources/core/theme/app_theme.dart';

void main() {
  group('Auth Login Screen Widget Tests', () {
    testWidgets('Login screen should display email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.theme(false, 1.0),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.text('StudySphere'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Validation errors should appear for empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.theme(false, 1.0),
            home: const LoginScreen(),
          ),
        ),
      );

      // Tap Login button without entering anything
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('Validation error for invalid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.theme(false, 1.0),
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });
  });
}
