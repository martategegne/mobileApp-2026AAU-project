import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import '../../domain/entities/notification.dart';

final notificationNotifierProvider = AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() async {
    final repository = ref.watch(notificationRepositoryProvider);
    return repository.getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadNotifications());
  }

  Future<void> addNotification({
    required String title,
    required String message,
  }) async {
    final repository = ref.read(notificationRepositoryProvider);
    final notification = AppNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      time: DateTime.now().toString(),
    );
    await repository.addNotification(notification);
    await refresh();
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAsRead(id);
    await refresh();
  }

  Future<void> clearAll() async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.clearAll();
    await refresh();
  }
}
