/// Collection of test matchers and custom expectations
import 'package:flutter_test/flutter_test.dart';

/// Matcher for valid email
Matcher isValidEmail() {
  return isA<String>().having(
    (email) => email.contains('@'),
    'contains @',
    true,
  );
}

/// Matcher for strong password
Matcher isStrongPassword() {
  return isA<String>()
      .having((pwd) => pwd.length >= 8, 'length >= 8', true)
      .having(
        (pwd) => pwd.contains(RegExp(r'[A-Z]')),
        'contains uppercase',
        true,
      )
      .having((pwd) => pwd.contains(RegExp(r'[0-9]')), 'contains number', true);
}

/// Matcher for valid URL
Matcher isValidUrl() {
  return isA<String>().having(
    (url) => url.startsWith('http'),
    'starts with http',
    true,
  );
}

/// Matcher for non-empty string
Matcher isNotEmpty() {
  return isA<String>().having((str) => str.isNotEmpty, 'is not empty', true);
}

/// Matcher for valid rating (0-5)
Matcher isValidRating() {
  return isA<double>()
      .having((rating) => rating >= 0, 'rating >= 0', true)
      .having((rating) => rating <= 5, 'rating <= 5', true);
}

/// Matcher for non-null and non-empty list
Matcher isNotEmptyList<T>() {
  return isA<List<T>>().having((list) => list.isNotEmpty, 'is not empty', true);
}

/// Matcher for positive integer
Matcher isPositive() {
  return isA<int>().having((value) => value > 0, 'is positive', true);
}

/// Matcher for valid user object
Matcher isValidUser() {
  return isA<Map<String, dynamic>>()
      .having((user) => user.containsKey('id'), 'has id', true)
      .having((user) => user.containsKey('email'), 'has email', true)
      .having((user) => user.containsKey('name'), 'has name', true);
}

/// Matcher for valid resource object
Matcher isValidResource() {
  return isA<Map<String, dynamic>>()
      .having((resource) => resource.containsKey('id'), 'has id', true)
      .having((resource) => resource.containsKey('title'), 'has title', true)
      .having(
        (resource) => resource.containsKey('description'),
        'has description',
        true,
      );
}

/// Custom expect for API response
void expectApiResponse(dynamic response, [int statusCode = 200]) {
  expect(response, isNotNull);
  if (response is Map) {
    expect(response.containsKey('success'), true);
  }
}
