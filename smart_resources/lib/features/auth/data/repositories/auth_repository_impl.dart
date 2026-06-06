import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.database, required this.network});

  final AppDatabase database;
  final NetworkService network;

  @override
  Future<User> login(String email, String password) async {
    final cachedUsers = await database.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (cachedUsers.isNotEmpty) {
      return UserModel.fromMap(cachedUsers.first);
    }

    final remoteUser = await network.authenticate(email, password);
    if (remoteUser == null) {
      throw AuthException('Invalid email or password.');
    }

    await database.insert('users', remoteUser.toMap());
    return remoteUser;
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    // Check duplicate only on the backend (source of truth)
    // Skipping local SQLite check to avoid false positives from cached data

    final id = 'user-${DateTime.now().microsecondsSinceEpoch}';
    final user = UserModel(
      id: id,
      name: name,
      email: email,
      password: password,
      role: 'User',
      status: 'active',
    );

    await database.insert('users', user.toMap());
    await network.register(user);
    return user;
  }

  @override
  Future<User> updateProfile(
    String id,
    String name,
    String email,
    String password,
  ) async {
    // Try local cache first to get existing role/status
    final cached = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    UserModel? existing;
    if (cached.isNotEmpty) {
      existing = UserModel.fromMap(cached.first);
    } else {
      // Not in cache — fetch from network
      try {
        final remoteList = await network.fetchUsers();
        final match = remoteList.where((u) => u.id == id);
        if (match.isNotEmpty) existing = match.first as UserModel;
      } catch (_) {}
    }

    // Build updated user — always preserve role and status
    final updatedUser = UserModel(
      id: id,
      name: name,
      email: email,
      password: password,
      role: existing?.role ?? 'User',
      status: existing?.status ?? 'active',
    );

    // Backend uses INSERT OR REPLACE — works even if user was deleted
    await network.updateUser(updatedUser);

    // Sync local cache
    await database.insert('users', updatedUser.toMap());

    return updatedUser;
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      // Always fetch from backend (source of truth)
      final remoteUsers = await network.fetchUsers();
      for (final user in remoteUsers) {
        await database.insert('users', user.toMap());
      }
      return remoteUsers;
    } catch (_) {
      // Network unavailable — fall back to local cache
      final cached = await database.query('users');
      return cached.map((row) => UserModel.fromMap(row)).toList();
    }
  }

  @override
  Future<void> toggleUserStatus(String id) async {
    final cachedUsers = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (cachedUsers.isEmpty) return;

    final user = UserModel.fromMap(cachedUsers.first);
    final updated = user.copyWith(
      status: user.status == 'active' ? 'suspended' : 'active',
    );

    await database.update(
      'users',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await network.updateUser(updated);
  }

  @override
  Future<void> deleteUser(String id) async {
    await database.delete('users', where: 'id = ?', whereArgs: [id]);
    await network.deleteUser(id);
  }
}
