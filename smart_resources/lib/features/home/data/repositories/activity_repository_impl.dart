import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final AppDatabase database;
  final NetworkService network;

  ActivityRepositoryImpl({required this.database, required this.network});

  @override
  Future<List<Activity>> getRecentActivities({String? userId}) async {
    // Check local cache first
    final rows = await database.query(
      'activities',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'time DESC',
      limit: 20,
    );

    if (rows.isNotEmpty) {
      return rows.map((row) => ActivityModel.fromMap(row)).toList();
    }

    // Cache miss — fetch from backend
    try {
      final remote = await network.fetchActivities(userId: userId);
      for (final a in remote) {
        final model = ActivityModel(
          id: a.id,
          userId: a.userId,
          userName: a.userName,
          type: a.type,
          title: a.title,
          time: a.time,
          referenceId: a.referenceId,
        );
        await database.insert('activities', model.toMap());
      }
      return remote;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> logActivity(Activity activity) async {
    final model = ActivityModel(
      id: activity.id,
      userId: activity.userId,
      userName: activity.userName,
      type: activity.type,
      title: activity.title,
      time: activity.time,
      referenceId: activity.referenceId,
    );
    // Save to backend
    try {
      await network.logActivity(activity);
    } catch (_) {}
    // Save to local SQLite cache
    await database.insert('activities', model.toMap());
  }
}
