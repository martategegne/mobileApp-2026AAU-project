import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getRecentActivities({String? userId});
  Future<void> logActivity(Activity activity);
}
