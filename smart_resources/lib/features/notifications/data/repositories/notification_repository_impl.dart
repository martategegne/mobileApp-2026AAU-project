import '../../../../core/database/app_database.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final AppDatabase database;

  NotificationRepositoryImpl({required this.database});

  @override
  Future<List<AppNotification>> getNotifications() async {
    final rows = await database.query(
      'notifications',
      orderBy: 'time DESC',
    );
    return rows.map((row) => NotificationModel.fromMap(row)).toList();
  }

  @override
  Future<void> addNotification(AppNotification notification) async {
    final model = NotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      time: notification.time,
      isRead: notification.isRead,
    );
    await database.insert('notifications', model.toMap());
  }

  @override
  Future<void> markAsRead(String id) async {
    await database.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAll() async {
    await database.delete('notifications', where: '1 = 1', whereArgs: []);
  }
}
