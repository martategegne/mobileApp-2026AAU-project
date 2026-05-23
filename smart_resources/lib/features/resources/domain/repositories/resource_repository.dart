import '../entities/resource.dart';
import '../entities/review.dart';

abstract class ResourceRepository {
  Future<List<Resource>> getResources();

  Future<Resource?> getResourceById(String id);

  Future<Resource> uploadResource(Resource resource);

  Future<void> updateResource(Resource resource);

  Future<void> bookmarkResource(String userId, String resourceId, bool isBookmarked);

  Future<void> markDownloaded(String id);

  Future<List<Resource>> getBookmarkedResources(String userId);

  Future<List<Resource>> getDownloadedResources();

  Future<void> approveResource(String id);

  Future<void> deleteResource(String id);

  Future<void> addReview(Review review);

  Future<List<Review>> getReviewsForResource(String resourceId);

  Future<int> getUserReviewCount(String userId);
}
