import 'package:flutter_test/flutter_test.dart';

/// Mock data for testing
class MockData {
  // User mock data
  static const String mockUserId = 'mock_user_123';
  static const String mockUserEmail = 'test@example.com';
  static const String mockUserName = 'Test User';
  static const String mockUserPassword = 'password123';

  // Resource mock data
  static const String mockResourceId = '123';
  static const String mockResourceTitle = 'Flutter Basics';
  static const String mockResourceDescription = 'Learn Flutter from scratch';
  static const String mockResourceCategory = 'books';
  static const String mockResourceUrl = 'https://example.com/resource/123';

  // Request mock data
  static const String mockRequestId = '456';
  static const String mockRequestReason = 'Need for project';
  static const String mockRequestStatus = 'pending';

  // Review mock data
  static const String mockReviewId = '789';
  static const int mockReviewRating = 5;
  static const String mockReviewComment = 'Great resource!';

  // Bookmark mock data
  static const String mockBookmarkId = 'bookmark_001';

  // Admin mock data
  static const String mockAdminEmail = 'admin@example.com';
  static const String mockAdminPassword = 'adminpass123';

  /// Get mock user data
  static Map<String, dynamic> getMockUser({
    String? id,
    String? email,
    String? name,
    bool isAdmin = false,
  }) {
    return {
      'id': id ?? mockUserId,
      'email': email ?? mockUserEmail,
      'name': name ?? mockUserName,
      'isAdmin': isAdmin,
    };
  }

  /// Get mock resource data
  static Map<String, dynamic> getMockResource({
    String? id,
    String? title,
    String? description,
    String? category,
    double rating = 4.5,
  }) {
    return {
      'id': id ?? mockResourceId,
      'title': title ?? mockResourceTitle,
      'description': description ?? mockResourceDescription,
      'category': category ?? mockResourceCategory,
      'rating': rating,
      'url': mockResourceUrl,
    };
  }

  /// Get mock request data
  static Map<String, dynamic> getMockRequest({
    String? id,
    String? resourceId,
    String? status,
    String? reason,
  }) {
    return {
      'id': id ?? mockRequestId,
      'resourceId': resourceId ?? mockResourceId,
      'status': status ?? mockRequestStatus,
      'reason': reason ?? mockRequestReason,
      'createdAt': DateTime.now(),
    };
  }

  /// Get mock review data
  static Map<String, dynamic> getMockReview({
    String? id,
    String? resourceId,
    int? rating,
    String? comment,
  }) {
    return {
      'id': id ?? mockReviewId,
      'resourceId': resourceId ?? mockResourceId,
      'rating': rating ?? mockReviewRating,
      'comment': comment ?? mockReviewComment,
      'createdAt': DateTime.now(),
    };
  }

  /// Get list of mock resources
  static List<Map<String, dynamic>> getMockResourcesList({int count = 10}) {
    return List.generate(
      count,
      (index) =>
          getMockResource(id: 'resource_$index', title: 'Resource $index'),
    );
  }

  /// Get list of mock requests
  static List<Map<String, dynamic>> getMockRequestsList({int count = 5}) {
    return List.generate(
      count,
      (index) =>
          getMockRequest(id: 'request_$index', resourceId: 'resource_$index'),
    );
  }

  /// Get list of mock reviews
  static List<Map<String, dynamic>> getMockReviewsList({int count = 5}) {
    return List.generate(
      count,
      (index) => getMockReview(
        id: 'review_$index',
        resourceId: mockResourceId,
        rating: (index % 5) + 1,
      ),
    );
  }
}
