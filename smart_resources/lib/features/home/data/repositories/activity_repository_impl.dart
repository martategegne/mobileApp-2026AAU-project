import '../../../../core/database/app_database.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final AppDatabase database;

  ActivityRepositoryImpl({required this.database});

  @override
  Future<List<Activity>> getRecentActivities({String? userId}) async {
    final rows = await database.query(
      'activities',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'time DESC',
      limit: 10,
    );
    return rows.map((row) => ActivityModel.fromMap(row)).toList();
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
    await database.insert('activities', model.toMap());
  }
}
