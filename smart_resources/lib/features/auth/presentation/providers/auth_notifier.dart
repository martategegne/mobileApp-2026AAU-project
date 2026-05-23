import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/features/home/domain/entities/activity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final userListProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(authRepositoryProvider).getUsers();
});

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  // Use ref.read to avoid circular dependency with authNotifierProvider
  final authState = ref.read(authNotifierProvider);
  final currentUser = authState.user;

  if (currentUser == null) {
    return const ProfileStats(uploads: 0, saved: 0, reviews: 0);
  }

  try {
    final repository = ref.read(resourceRepositoryProvider);
    final resources = await repository.getResources();
    final bookmarked = await repository.getBookmarkedResources(currentUser.id);
    final reviewsCount = await repository.getUserReviewCount(currentUser.id);
    final uploadsCount = resources.where((item) => item.uploader == currentUser.name).length;
    final savedCount = bookmarked.length;
    return ProfileStats(uploads: uploadsCount, saved: savedCount, reviews: reviewsCount);
  } catch (e) {
    return const ProfileStats(uploads: 0, saved: 0, reviews: 0);
  }
});

class ProfileStats {
  final int uploads;
  final int saved;
  final int reviews;

  const ProfileStats({
    required this.uploads,
    required this.saved,
    required this.reviews,
  });
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _logActivity(String userId, String userName, String type, String title) async {
    try {
      final activityRepo = ref.read(activityRepositoryProvider);
      await activityRepo.logActivity(Activity(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        type: type,
        title: title,
        time: DateTime.now().toString(),
      ));
    } catch (_) {
      // Non-critical logging — never fail the main operation
    }
  }

  Future<void> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      if (user.status.toLowerCase() != 'active') {
        throw AuthException('This account is inactive or suspended.');
      }
      if (role.toLowerCase() != user.role.toLowerCase()) {
        throw AuthException('Selected role does not match account role.');
      }
      state = AuthState(user: user, isLoading: false);
    } catch (error) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: error is AuthException ? error.message : error.toString(),
      );
    }
  }

  /// Returns true on success, false on failure.
  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signup(name, email, password);
      state = AuthState(user: user, isLoading: false);
      await _logActivity(user.id, user.name, 'signup', 'joined the platform');
      ref.invalidate(userListProvider);
      return true;
    } catch (error) {
      state = AuthState(
        user: null,
        isLoading: false,
        error: error is AuthException ? error.message : error.toString(),
      );
      return false;
    }
  }

  Future<void> updateProfile(String id, String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.updateProfile(id, name, email, password);
      state = AuthState(user: updated, isLoading: false);
      ref.invalidate(userListProvider);
      ref.invalidate(profileStatsProvider);
      await _logActivity(updated.id, updated.name, 'profile_update', 'updated profile information');
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> toggleUserStatus(String id) async {
    final users = await ref.read(userListProvider.future);
    final targetUser = users.firstWhere((u) => u.id == id);
    final action = targetUser.status == 'active' ? 'suspended' : 'activated';
    await _repository.toggleUserStatus(id);
    final currentUser = state.user;
    if (currentUser != null) {
      await _logActivity(currentUser.id, currentUser.name, 'profile_update', "$action user '${targetUser.name}'");
    }
    ref.invalidate(userListProvider);
  }

  Future<void> deleteUser(String id) async {
    final users = await ref.read(userListProvider.future);
    final targetUser = users.firstWhere((u) => u.id == id);
    await _repository.deleteUser(id);
    final currentUser = state.user;
    if (currentUser != null) {
      await _logActivity(currentUser.id, currentUser.name, 'profile_update', "deleted user '${targetUser.name}'");
    }
    ref.invalidate(userListProvider);
  }

  Future<void> logout() async {
    state = const AuthState();
  }
}
