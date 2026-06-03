import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/features/notifications/presentation/providers/notification_notifier.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () =>
                ref.read(notificationNotifierProvider.notifier).clearAll(),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.mediumGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notif.isRead
                      ? AppColors.lightGrey
                      : AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: notif.isRead
                        ? AppColors.mediumGrey
                        : AppColors.primary,
                  ),
                ),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: notif.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.message),
                    const SizedBox(height: 4),
                    Text(
                      notif.time.split(' ')[0], // Simple date display
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (!notif.isRead) {
                    ref
                        .read(notificationNotifierProvider.notifier)
                        .markAsRead(notif.id);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
