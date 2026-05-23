import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> addNotification(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> clearAll();
}
