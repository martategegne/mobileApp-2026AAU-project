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
    final existingLocal = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existingLocal.isNotEmpty) {
      throw AuthException('An account with this email already exists.');
    }

    final remoteUsers = await network.fetchUsers();
    if (remoteUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw AuthException('An account with this email already exists.');
    }

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
  Future<User> updateProfile(String id, String name, String email, String password) async {
    final cached = await database.query('users', where: 'id = ?', whereArgs: [id]);
    if (cached.isEmpty) throw AuthException('User not found');
    
    final existingUser = UserModel.fromMap(cached.first);
    final updatedUser = existingUser.copyWith(
      name: name,
      email: email,
      password: password,
    );

    await database.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Sync with network/auth state
    await network.updateUser(updatedUser);
    
    return updatedUser;
  }

  @override
  Future<List<User>> getUsers() async {
    final cached = await database.query('users');
    if (cached.isNotEmpty) {
      return cached.map((row) => UserModel.fromMap(row)).toList();
    }

    final remoteUsers = await network.fetchUsers();
    for (final user in remoteUsers) {
      await database.insert('users', user.toMap());
    }
    return remoteUsers;
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
