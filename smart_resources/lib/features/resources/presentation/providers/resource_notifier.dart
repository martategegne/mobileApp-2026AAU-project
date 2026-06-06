import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/core/utils/web_download.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/home/presentation/providers/activity_notifier.dart';
import 'package:smart_resources/features/notifications/presentation/providers/notification_notifier.dart';
import '../../domain/entities/review.dart';
import '../../data/models/resource_model.dart';

final resourceNotifierProvider = AsyncNotifierProvider<ResourceNotifier, List<ResourceModel>>(
  ResourceNotifier.new,
);

final resourceDetailsProvider = FutureProvider.family<ResourceModel?, String>(
  (ref, id) async {
    final resource = await ref.watch(resourceRepositoryProvider).getResourceById(id);
    final user = ref.watch(authNotifierProvider).user;
    if (resource == null) return null;
    
    bool isBookmarked = false;
    if (user != null) {
      final bookmarked = await ref.watch(resourceRepositoryProvider).getBookmarkedResources(user.id);
      isBookmarked = bookmarked.any((r) => r.id == id);
    }
    
    return (resource as ResourceModel).copyWith(isBookmarked: isBookmarked);
  },
);

final resourceReviewsProvider = FutureProvider.family<List<Review>, String>((ref, resourceId) {
  return ref.watch(resourceRepositoryProvider).getReviewsForResource(resourceId);
});

final bookmarkedResourcesProvider = FutureProvider<List<ResourceModel>>(
  (ref) async {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null) return [];
    final resources = await ref.watch(resourceRepositoryProvider).getBookmarkedResources(user.id);
    return resources.cast<ResourceModel>();
  },
);

final downloadedResourcesProvider = FutureProvider<List<ResourceModel>>(
  (ref) async {
    final resources = await ref.watch(resourceRepositoryProvider).getDownloadedResources();
    return resources.cast<ResourceModel>();
  },
);

class ResourceNotifier extends AsyncNotifier<List<ResourceModel>> {
  // Backend base URL — matches NetworkService
  static const _backendBase = 'http://localhost:3000';

  @override
  Future<List<ResourceModel>> build() async {
    return _loadResources();
  }

  Future<List<ResourceModel>> _loadResources() async {
    final repository = ref.watch(resourceRepositoryProvider);
    final user = ref.watch(authNotifierProvider).user;
    final allResources = await repository.getResources();

    // Admins see all resources; students only see approved ones
    final isAdmin = user?.isAdmin ?? false;
    final resources = isAdmin
        ? allResources
        : allResources.where((r) => (r as ResourceModel).isApproved).toList();

    if (user == null) return resources.cast<ResourceModel>();

    final bookmarked = await repository.getBookmarkedResources(user.id);
    final bookmarkedIds = bookmarked.map((r) => r.id).toSet();

    return resources.map((r) {
      return (r as ResourceModel).copyWith(isBookmarked: bookmarkedIds.contains(r.id));
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadResources());
    ref.invalidate(bookmarkedResourcesProvider);
    ref.invalidate(downloadedResourcesProvider);
    ref.invalidate(profileStatsProvider);
  }

  Future<void> uploadResource(
    ResourceModel resource, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.uploadResource(
      resource,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    
    final user = ref.read(authNotifierProvider).user;
    
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'upload',
      title: "uploaded '${resource.title}'",
      referenceId: resource.id,
    );

    await ref.read(notificationNotifierProvider.notifier).addNotification(
      title: 'New Resource Available',
      message: '${user?.name ?? 'Someone'} uploaded ${resource.title}',
    );

    await refresh();
  }

  Future<void> updateResource(ResourceModel resource) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.updateResource(resource);
    
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'profile_update',
      title: "updated resource '${resource.title}'",
      referenceId: resource.id,
    );

    await refresh();
    ref.invalidate(resourceDetailsProvider(resource.id));
  }

  Future<void> toggleBookmark(String resourceId, bool isBookmarked) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final repository = ref.read(resourceRepositoryProvider);
    await repository.bookmarkResource(user.id, resourceId, isBookmarked);

    await refresh();
    ref.invalidate(resourceDetailsProvider(resourceId));
  }

  Future<void> markDownloaded(String id) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.markDownloaded(id);

    final resource = await repository.getResourceById(id);
    if (resource != null) {
      await ref.read(activityNotifierProvider.notifier).logActivity(
        type: 'download',
        title: "downloaded '${resource.title}'",
        referenceId: id,
      );

      // Trigger the actual file download in the browser (web)
      // or skip gracefully on mobile (open_filex not needed for web builds)
      final filePath = (resource as ResourceModel).filePath;
      if (filePath != null && filePath.isNotEmpty) {
        final fullUrl = filePath.startsWith('http')
            ? filePath
            : '$_backendBase$filePath';

        if (kIsWeb) {
          // triggerWebDownload is conditionally imported — no-op on non-web
          triggerWebDownload(fullUrl, '${resource.title}.${resource.fileType.toLowerCase()}');
        }
        // For mobile: add url_launcher or open_filex here when needed
      }
    }

    await refresh();
    ref.invalidate(resourceDetailsProvider(id));
  }

  Future<void> approveResource(String id) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.approveResource(id);
    
    final resource = await repository.getResourceById(id);
    if (resource != null) {
      await ref.read(activityNotifierProvider.notifier).logActivity(
        type: 'upload',
        title: "approved resource '${resource.title}'",
        referenceId: id,
      );
    }

    await refresh();
    ref.invalidate(resourceDetailsProvider(id));
  }

  Future<void> deleteResource(String id) async {
    final repository = ref.read(resourceRepositoryProvider);
    final resource = await repository.getResourceById(id);
    final title = resource?.title ?? 'a resource';
    
    await repository.deleteResource(id);
    
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'upload',
      title: "deleted resource '$title'",
    );

    await refresh();
  }

  Future<void> addReview(Review review) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.addReview(review);

    final resource = await repository.getResourceById(review.resourceId);
    if (resource != null) {
      await ref.read(activityNotifierProvider.notifier).logActivity(
        type: 'review',
        title: "reviewed '${resource.title}'",
        referenceId: review.resourceId,
      );
    }

    await refresh();
    ref.invalidate(resourceDetailsProvider(review.resourceId));
    ref.invalidate(resourceReviewsProvider(review.resourceId));
    ref.invalidate(profileStatsProvider);
  }
}
