# Testing Guide for Smart Resources App

## Overview
This directory contains comprehensive tests for the Smart Resources Flutter application, including unit tests, widget tests, Riverpod provider tests, and integration tests.

## Test Structure

```
test/
├── unit/                          # Unit tests for services and business logic
│   ├── auth/                      # Authentication service tests
│   ├── resources/                 # Resource service tests
│   ├── requests/                  # Request handling tests
│   ├── reviews/                   # Review service tests
│   ├── bookmarks/                 # Bookmark service tests
│   └── shared/                    # Shared utilities and validators
│
├── widget/                        # Widget and UI tests
│   ├── auth/                      # Authentication screens
│   ├── home/                      # Home screen tests
│   ├── resources/                 # Resource screens
│   ├── requests/                  # Request screens
│   ├── reviews/                   # Review screens
│   ├── bookmarks/                 # Bookmark screens
│   └── common_widgets/            # Common UI component tests
│
├── riverpod/                      # State management (Riverpod) tests
│   ├── auth_providers_test.dart
│   ├── resource_providers_test.dart
│   ├── request_providers_test.dart
│   ├── review_providers_test.dart
│   └── bookmark_providers_test.dart
│
└── integration_test/              # End-to-end integration tests
    ├── auth_flow_test.dart        # Authentication flows
    ├── student_flow_test.dart     # Student user workflows
    ├── admin_flow_test.dart       # Admin user workflows
    ├── resource_management_test.dart
    ├── request_flow_test.dart
    ├── review_flow_test.dart
    └── bookmark_flow_test.dart
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/unit/auth/auth_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run widget tests only
```bash
flutter test test/widget/
```

### Run integration tests
```bash
flutter test integration_test/
```

### Run tests with verbose output
```bash
flutter test --verbose
```

### Run tests with specific pattern
```bash
flutter test -k "Auth"
```

## Test Categories

### 1. Unit Tests (`test/unit/`)
These tests verify the business logic and services in isolation without UI.

- **auth_service_test.dart**: Login, signup, logout, password reset
- **resource_service_test.dart**: Fetch, search, create, delete resources
- **request_service_test.dart**: Create, approve, reject requests
- **review_service_test.dart**: Submit, fetch, update, delete reviews
- **bookmark_service_test.dart**: Add, remove, search bookmarks
- **validation_test.dart**: Email, password, name validation

### 2. Widget Tests (`test/widget/`)
These tests verify UI components and user interactions.

- **auth_screen_test.dart**: Login and signup screen functionality
- **home_screen_test.dart**: Home screen navigation and features
- **resource_screen_test.dart**: Resource listing and filtering
- **request_screen_test.dart**: Request submission and management
- **review_screen_test.dart**: Review submission and display
- **bookmark_screen_test.dart**: Bookmark management
- **common_widgets_test.dart**: Reusable UI components

### 3. Riverpod Tests (`test/riverpod/`)
These tests verify state management and provider behavior.

- **auth_providers_test.dart**: Authentication state and providers
- **resource_providers_test.dart**: Resource data fetching and caching
- **request_providers_test.dart**: Request state management
- **review_providers_test.dart**: Review data management
- **bookmark_providers_test.dart**: Bookmark state management

### 4. Integration Tests (`test/integration_test/`)
These tests verify complete workflows across the application.

- **auth_flow_test.dart**: Complete authentication flows (signup, login, logout)
- **student_flow_test.dart**: Student user workflows (browse, request, review, bookmark)
- **admin_flow_test.dart**: Admin user workflows (manage requests, upload resources)
- **resource_management_test.dart**: Complete resource lifecycle (CRUD operations)
- **request_flow_test.dart**: Request workflow (create, approve, reject)
- **review_flow_test.dart**: Review workflow (submit, edit, delete)
- **bookmark_flow_test.dart**: Bookmark workflow (add, remove, search)

## Best Practices

### 1. Naming Conventions
```dart
// Good
testWidgets('Login button should be disabled when fields are empty', ...)
test('Email validation should reject invalid email', ...)

// Avoid
testWidgets('test', ...)
test('test1', ...)
```

### 2. Test Structure (AAA Pattern)
```dart
testWidgets('Feature description', (WidgetTester tester) async {
  // Arrange - Set up test data and conditions
  
  // Act - Perform the action
  
  // Assert - Verify the result
});
```

### 3. Using Mock Data
```dart
import 'shared/mock_data.dart';

test('should return user', () {
  final mockUser = MockData.getMockUser();
  expect(mockUser['email'], equals(MockData.mockUserEmail));
});
```

### 4. Using Helper Functions
```dart
import 'shared/test_helper.dart';

testWidgets('should submit form', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  await TestHelper.fillForm(tester, {
    const Key('email_field'): 'test@example.com',
    const Key('password_field'): 'password123',
  });
  
  await TestHelper.tapAndNavigate(tester, find.byKey(const Key('submit_button')));
});
```

## Common Testing Patterns

### Testing Async Operations
```dart
test('async operation should complete', () async {
  final result = await someAsyncFunction();
  expect(result, isNotNull);
});
```

### Testing Exceptions
```dart
test('should throw exception', () {
  expect(
    () => functionThatThrows(),
    throwsException,
  );
});
```

### Testing Widget Rendering
```dart
testWidgets('widget should render', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### Testing User Input
```dart
testWidgets('should handle input', (WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'input text');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
});
```

## Coverage Goals
- **Unit Tests**: 80%+ coverage
- **Widget Tests**: 60%+ coverage
- **Integration Tests**: Critical user flows

## CI/CD Integration
Tests should be run in continuous integration pipeline:

```bash
# In your CI configuration
flutter clean
flutter pub get
flutter test --coverage
```

## Troubleshooting

### Test Times Out
```dart
testWidgets('test', (WidgetTester tester) async {
  // Set custom timeout
  tester.binding.window.physicalSizeTestValue = const Size(800, 600);
});
```

### Widget Not Found
```dart
// Use pumpAndSettle() to wait for all animations
await tester.pumpAndSettle();

// Explicitly wait for widget
await tester.pumpAndSettle(const Duration(seconds: 5));
```

### State Not Updating
```dart
// Rebuild widget after state change
await tester.pumpWidget(const MyApp());
await tester.pumpAndSettle();
```

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Flutter Widget Testing Guide](https://flutter.dev/docs/testing/unit-tests)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)

## Contributing

When adding new features:
1. Write unit tests first (TDD approach)
2. Add widget tests for UI components
3. Update Riverpod provider tests if state changes
4. Add integration tests for new workflows
5. Maintain test coverage above 70%

## Test Execution Summary

```bash
# Run all tests with summary
flutter test --reporter compact

# Run with detailed output
flutter test --verbose

# Generate coverage report
flutter test --coverage
lcov --list coverage/lcov.info
```

---
**Last Updated**: 2026-06-03
**Status**: Active Development
