import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/home/presentation/providers/activity_notifier.dart';
import 'package:smart_resources/features/notifications/presentation/providers/notification_notifier.dart';
import 'package:open_filex/open_filex.dart';
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
  @override
  Future<List<ResourceModel>> build() async {
    return _loadResources();
  }

  Future<List<ResourceModel>> _loadResources() async {
    final repository = ref.watch(resourceRepositoryProvider);
    final user = ref.watch(authNotifierProvider).user;
    final resources = await repository.getResources();
    
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

  Future<void> uploadResource(ResourceModel resource) async {
    final repository = ref.read(resourceRepositoryProvider);
    await repository.uploadResource(resource);
    
    final user = ref.read(authNotifierProvider).user;
    
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'upload',
      title: "uploaded '${resource.title}'",
      referenceId: resource.id,
    );

    // Global Notification for all users
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

    if (isBookmarked) {
      final resource = await repository.getResourceById(resourceId);
      if (resource != null) {
        await ref.read(activityNotifierProvider.notifier).logActivity(
          type: 'bookmark',
          title: "bookmarked '${resource.title}'",
          referenceId: resourceId,
        );
      }
    }

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
      
      if (resource.filePath != null) {
        await OpenFilex.open(resource.filePath!);
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
