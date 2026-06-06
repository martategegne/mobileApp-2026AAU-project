import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      // Always fetch from backend (source of truth)
      final remoteResources = await network.fetchResources();
      // Sync to local SQLite cache
      for (final resource in remoteResources) {
        await database.insert('resources', resource.toMap());
      }
      return remoteResources;
    } catch (_) {
      // Network unavailable — fall back to local cache
      return _fetchLocalResources();
    }
  }

  @override
  Future<Resource?> getResourceById(String id) async {
    final rows = await database.query(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isNotEmpty) {
      return ResourceModel.fromMap(rows.first);
    }

    final remote = await network.fetchResourceById(id);
    if (remote == null) return null;
    await database.insert('resources', remote.toMap());
    return remote;
  }

  @override
  Future<Resource> uploadResource(
    Resource resource, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
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

    // Pass file bytes through to NetworkService so it can do a multipart upload
    final remote = await network.uploadResource(
      model,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    // Cache locally (file_path will be the server-assigned URL now)
    await database.insert('resources', remote.toMap());
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
    await network.updateResource(model);
    await database.update(
      'resources',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  @override
  Future<void> bookmarkResource(
    String userId,
    String resourceId,
    bool isBookmarked,
  ) async {
    if (isBookmarked) {
      await network.addBookmark(userId, resourceId);
      await database.insert('bookmarks', {
        'user_id': userId,
        'resource_id': resourceId,
      });
    } else {
      await network.removeBookmark(userId, resourceId);
      await database.delete(
        'bookmarks',
        where: 'user_id = ? AND resource_id = ?',
        whereArgs: [userId, resourceId],
      );
    }
    final row = await database.query(
      'resources',
      where: 'id = ?',
      whereArgs: [resourceId],
    );
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
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('downloaded_ids') ?? [];
    if (!downloaded.contains(id)) {
      downloaded.add(id);
      await prefs.setStringList('downloaded_ids', downloaded);
    }
  }

  @override
  Future<List<Resource>> getBookmarkedResources(String userId) async {
    final bookmarkRows = await database.query(
      'bookmarks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final resourceIds = bookmarkRows
        .map((row) => row['resource_id'] as String)
        .toList();

    if (resourceIds.isNotEmpty) {
      final placeholders = List.filled(resourceIds.length, '?').join(',');
      final rows = await database.query(
        'resources',
        where: "id IN ($placeholders)",
        whereArgs: resourceIds,
      );
      return rows
          .map((row) => ResourceModel.fromMap(row).copyWith(isBookmarked: true))
          .toList();
    }

    // Fall back to API if local cache is empty (web compatibility)
    final remoteResources = await network.fetchBookmarks(userId);
    for (final resource in remoteResources) {
      await database.insert('bookmarks', {
        'user_id': userId,
        'resource_id': resource.id,
      });
      await database.insert('resources', resource.toMap());
    }
    return remoteResources.map((r) => r.copyWith(isBookmarked: true)).toList();
  }

  @override
  Future<List<Resource>> getDownloadedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedIds = prefs.getStringList('downloaded_ids') ?? [];
    if (downloadedIds.isEmpty) return [];
    final all = await network.fetchResources();
    return all.where((r) => downloadedIds.contains(r.id)).toList();
  }

  @override
  Future<void> approveResource(String id) async {
    await network.approveResource(id);
    final rows = await database.query(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
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
    await network.deleteResource(id);
    await database.delete('resources', where: 'id = ?', whereArgs: [id]);
    await database.delete(
      'bookmarks',
      where: 'resource_id = ?',
      whereArgs: [id],
    );
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
    await network.addReview(model);
    await database.insert('reviews', model.toMap());

    final rows = await database.query(
      'resources',
      where: 'id = ?',
      whereArgs: [review.resourceId],
    );
    if (rows.isNotEmpty) {
      final resource = ResourceModel.fromMap(rows.first);
      final newCount = resource.reviewCount + 1;
      final newRating =
          ((resource.rating * resource.reviewCount) + review.rating) / newCount;
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
    final rows = await database.query(
      'reviews',
      where: 'resource_id = ?',
      whereArgs: [resourceId],
    );
    if (rows.isNotEmpty) {
      return rows.map((row) => ReviewModel.fromMap(row)).toList();
    }
    final remoteReviews = await network.fetchReviews(resourceId);
    for (final review in remoteReviews) {
      await database.insert('reviews', review.toMap());
    }
    return remoteReviews;
  }

  @override
  Future<int> getUserReviewCount(String userId) async {
    final rows = await database.query(
      'reviews',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.length;
  }
}
