import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'network/network_service.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/requests/data/repositories/request_repository_impl.dart';
import '../features/requests/domain/repositories/request_repository.dart';
import '../features/resources/data/repositories/resource_repository_impl.dart';
import '../features/resources/domain/repositories/resource_repository.dart';
import '../features/home/domain/repositories/activity_repository.dart';
import '../features/home/data/repositories/activity_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    network: ref.watch(networkServiceProvider),
  );
});

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    network: ref.watch(networkServiceProvider),
  );
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    network: ref.watch(networkServiceProvider),
  );
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
  );
});
