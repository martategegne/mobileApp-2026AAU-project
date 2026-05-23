import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/home/presentation/providers/activity_notifier.dart';
import 'package:smart_resources/features/notifications/presentation/providers/notification_notifier.dart';
import '../../data/models/request_model.dart';

final requestNotifierProvider = AsyncNotifierProvider<RequestNotifier, List<RequestModel>>(
  RequestNotifier.new,
);

class RequestNotifier extends AsyncNotifier<List<RequestModel>> {
  @override
  Future<List<RequestModel>> build() async {
    return _loadRequests();
  }

  Future<List<RequestModel>> _loadRequests() async {
    final repository = ref.watch(requestRepositoryProvider);
    final items = await repository.getRequests();
    return items.cast<RequestModel>();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadRequests());
  }

  Future<void> createRequest(RequestModel request) async {
    final repository = ref.read(requestRepositoryProvider);
    await repository.createRequest(request);

    final user = ref.read(authNotifierProvider).user;

    // Log Activity
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'request',
      title: "requested '${request.title}'",
      referenceId: request.id,
    );

    // Global Notification
    await ref.read(notificationNotifierProvider.notifier).addNotification(
      title: 'New Resource Request',
      message: '${user?.name ?? 'Someone'} is looking for ${request.title}',
    );

    await refresh();
  }

  Future<void> updateRequest(RequestModel request) async {
    final repository = ref.read(requestRepositoryProvider);
    await repository.updateRequest(request);
    
    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'profile_update',
      title: "updated request '${request.title}'",
      referenceId: request.id,
    );

    await refresh();
  }

  Future<void> deleteRequest(String id) async {
    final repository = ref.read(requestRepositoryProvider);
    // Try to get title before deleting
    final requests = state.value ?? [];
    final request = requests.firstWhere((r) => r.id == id);
    
    await repository.deleteRequest(id);

    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'request',
      title: "deleted request '${request.title}'",
    );

    await refresh();
  }

  Future<void> fulfillRequest(String id) async {
    final repository = ref.read(requestRepositoryProvider);
    await repository.fulfillRequest(id);
    
    final requests = state.value ?? [];
    final request = requests.firstWhere((r) => r.id == id);

    await ref.read(activityNotifierProvider.notifier).logActivity(
      type: 'request',
      title: "fulfilled request '${request.title}'",
      referenceId: id,
    );

    await refresh();
  }
}
