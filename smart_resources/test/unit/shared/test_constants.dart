/// Test constants used across the test suite
class TestConstants {
  // Test user credentials
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'Test@1234';
  static const String testUserName = 'Test User';

  // Test admin credentials
  static const String adminEmail = 'admin@example.com';
  static const String adminPassword = 'Admin@1234';

  // Test resource data
  static const String resourceTitle = 'Test Resource';
  static const String resourceDescription = 'This is a test resource';
  static const String resourceCategory = 'books';

  // Test request data
  static const String requestReason = 'Needed for study';
  static const String rejectionReason = 'Not available';

  // Test review data
  static const String reviewComment = 'Great resource!';
  static const int reviewRating = 5;

  // Timeouts
  static const Duration shortTimeout = Duration(milliseconds: 500);
  static const Duration normalTimeout = Duration(seconds: 2);
  static const Duration longTimeout = Duration(seconds: 5);

  // Common test keys
  static const String emailFieldKey = 'email_field';
  static const String passwordFieldKey = 'password_field';
  static const String loginButtonKey = 'login_button';
  static const String signupButtonKey = 'signup_button';
  static const String submitButtonKey = 'submit_button';
  static const String cancelButtonKey = 'cancel_button';
  static const String deleteButtonKey = 'delete_button';
  static const String editButtonKey = 'edit_button';

  // UI Text constants
  static const String loadingText = 'Loading...';
  static const String errorText = 'An error occurred';
  static const String emptyStateText = 'No items found';
  static const String successText = 'Success';
  static const String confirmText = 'Confirm';
  static const String cancelText = 'Cancel';

  // API endpoints for mocking
  static const String baseUrl = 'https://api.example.com';
  static const String authEndpoint = '/api/auth';
  static const String resourcesEndpoint = '/api/resources';
  static const String requestsEndpoint = '/api/requests';
  static const String reviewsEndpoint = '/api/reviews';
  static const String bookmarksEndpoint = '/api/bookmarks';
}
