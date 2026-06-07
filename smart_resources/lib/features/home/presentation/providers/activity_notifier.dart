import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';

final activityNotifierProvider = AsyncNotifierProvider<ActivityNotifier, List<Activity>>(
  ActivityNotifier.new,
);

class ActivityNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    return _loadActivities();
  }

  Future<List<Activity>> _loadActivities() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return [];

    final repository = ref.read(activityRepositoryProvider);
    final all = await repository.getRecentActivities(userId: user.id);

    // Only show activities from the last 2 minutes
    final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
    return all.where((a) {
      try {
        final time = DateTime.parse(a.time);
        return time.isAfter(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadActivities());
  }

  Future<void> logActivity({
    required String type,
    required String title,
    String? referenceId,
  }) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final repository = ref.read(activityRepositoryProvider);
    final activity = Activity(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      type: type,
      title: title,
      time: DateTime.now().toString(),
      referenceId: referenceId,
    );

    await repository.logActivity(activity);
    await refresh();
  }
}
