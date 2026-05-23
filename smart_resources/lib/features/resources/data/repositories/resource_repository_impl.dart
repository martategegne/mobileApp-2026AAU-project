import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/resource.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/resource_repository.dart';
import '../models/resource_model.dart';
import '../models/review_model.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  ResourceRepositoryImpl({required this.database, required this.network});

  final AppDatabase database;
  final NetworkService network;

  Future<List<ResourceModel>> _fetchLocalResources() async {
    final rows = await database.query('resources');
    return rows.map((row) => ResourceModel.fromMap(row)).toList();
  }

  @override
  Future<List<Resource>> getResources() async {
    final localResources = await _fetchLocalResources();
    if (localResources.isNotEmpty) {
      return localResources;
    }

    final remoteResources = await network.fetchResources();
    for (final resource in remoteResources) {
      await database.insert('resources', resource.toMap());
    }
    return remoteResources;
  }

  @override
  Future<Resource?> getResourceById(String id) async {
    final rows = await database.query('resources', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      return ResourceModel.fromMap(rows.first);
    }

    final remote = await network.fetchResourceById(id);
    if (remote == null) return null;
    await database.insert('resources', remote.toMap());
    return remote;
  }

  @override
  Future<Resource> uploadResource(Resource resource) async {
    final model = ResourceModel(
      id: resource.id,
      title: resource.title,
      description: resource.description,
      courseCode: resource.courseCode,
      rating: resource.rating,
      reviewCount: resource.reviewCount,
      uses: resource.uses,
      fileType: resource.fileType,
      uploader: resource.uploader,
      isApproved: resource.isApproved,
      isBookmarked: resource.isBookmarked,
      isDownloaded: resource.isDownloaded,
      filePath: resource.filePath,
    );
    
    final remote = await network.uploadResource(model);
    await database.insert('resources', model.toMap());
    return remote;
  }

  @override
  Future<void> updateResource(Resource resource) async {
    final model = ResourceModel(
      id: resource.id,
      title: resource.title,
      description: resource.description,
      courseCode: resource.courseCode,
      rating: resource.rating,
      reviewCount: resource.reviewCount,
      uses: resource.uses,
      fileType: resource.fileType,
      uploader: resource.uploader,
      isApproved: resource.isApproved,
      isBookmarked: resource.isBookmarked,
      isDownloaded: resource.isDownloaded,
      filePath: resource.filePath,
    );
    await database.update(
      'resources',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  @override
  Future<void> bookmarkResource(String userId, String resourceId, bool isBookmarked) async {
    if (isBookmarked) {
      await database.insert('bookmarks', {
        'user_id': userId,
        'resource_id': resourceId,
      });
    } else {
      await database.delete('bookmarks', 
        where: 'user_id = ? AND resource_id = ?', 
        whereArgs: [userId, resourceId],
      );
    }
    
    final row = await database.query('resources', where: 'id = ?', whereArgs: [resourceId]);
    if (row.isNotEmpty) {
      final resource = ResourceModel.fromMap(row.first);
      await database.update(
        'resources',
        resource.copyWith(isBookmarked: isBookmarked).toMap(),
        where: 'id = ?',
        whereArgs: [resourceId],
      );
    }
  }

  @override
  Future<void> markDownloaded(String id) async {
    final row = await database.query('resources', where: 'id = ?', whereArgs: [id]);
    if (row.isEmpty) return;
    final resource = ResourceModel.fromMap(row.first);
    await database.update(
      'resources',
      resource.copyWith(isDownloaded: true, uses: resource.uses + 1).toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Resource>> getBookmarkedResources(String userId) async {
    final bookmarkRows = await database.query('bookmarks', where: 'user_id = ?', whereArgs: [userId]);
    final resourceIds = bookmarkRows.map((row) => row['resource_id'] as String).toList();
    
    if (resourceIds.isEmpty) return [];

    final placeholders = List.filled(resourceIds.length, '?').join(',');
    final rows = await database.query(
      'resources',
      where: "id IN ($placeholders)",
      whereArgs: resourceIds,
    );
    
    return rows.map((row) => ResourceModel.fromMap(row).copyWith(isBookmarked: true)).toList();
  }

  @override
  Future<List<Resource>> getDownloadedResources() async {
    final rows = await database.query(
      'resources',
      where: 'isDownloaded = ?',
      whereArgs: [1],
    );
    return rows.map((row) => ResourceModel.fromMap(row)).toList();
  }

  @override
  Future<void> approveResource(String id) async {
    final rows = await database.query('resources', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final resource = ResourceModel.fromMap(rows.first);
    await database.update(
      'resources',
      resource.copyWith(isApproved: true).toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteResource(String id) async {
    await database.delete('resources', where: 'id = ?', whereArgs: [id]);
    await database.delete('bookmarks', where: 'resource_id = ?', whereArgs: [id]);
    await database.delete('reviews', where: 'resource_id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addReview(Review review) async {
    final model = ReviewModel(
      id: review.id,
      resourceId: review.resourceId,
      userId: review.userId,
      userName: review.userName,
      rating: review.rating,
      comment: review.comment,
      time: review.time,
    );
    await database.insert('reviews', model.toMap());

    final rows = await database.query('resources', where: 'id = ?', whereArgs: [review.resourceId]);
    if (rows.isNotEmpty) {
      final resource = ResourceModel.fromMap(rows.first);
      final newCount = resource.reviewCount + 1;
      final newRating = ((resource.rating * resource.reviewCount) + review.rating) / newCount;
      await database.update(
        'resources',
        resource.copyWith(rating: newRating, reviewCount: newCount).toMap(),
        where: 'id = ?',
        whereArgs: [review.resourceId],
      );
    }
  }

  @override
  Future<List<Review>> getReviewsForResource(String resourceId) async {
    final rows = await database.query('reviews', where: 'resource_id = ?', whereArgs: [resourceId]);
    return rows.map((row) => ReviewModel.fromMap(row)).toList();
  }

  @override
  Future<int> getUserReviewCount(String userId) async {
    final rows = await database.query('reviews', where: 'user_id = ?', whereArgs: [userId]);
    return rows.length;
  }
}
