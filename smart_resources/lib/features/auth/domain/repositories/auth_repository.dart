import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);

  Future<User> signup(String name, String email, String password);

  Future<User> updateProfile(String id, String name, String email, String password);

  Future<List<User>> getUsers();

  Future<void> toggleUserStatus(String id);

  Future<void> deleteUser(String id);
}
