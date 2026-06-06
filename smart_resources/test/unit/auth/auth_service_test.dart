import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_resources/features/auth/domain/entities/user.dart';
import 'package:smart_resources/features/auth/data/models/user_model.dart';
import 'package:smart_resources/core/database/app_database.dart';
import 'package:smart_resources/core/network/network_service.dart';

// Simple fakes for unit testing
class FakeDatabase extends Fake implements AppDatabase {
  @override
  Future<List<Map<String, Object?>>> query(String table,
      {String? where,
      List<Object?>? whereArgs,
      bool? distinct,
      List<String>? columns,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async =>
      [];

  @override
  Future<int> insert(String table, Map<String, Object?> values) async => 1;
}

class FakeNetwork extends Fake implements NetworkService {
  @override
  Future<UserModel?> authenticate(String email, String password) async {
    return UserModel(
      id: '1',
      name: 'Test User',
      email: email,
      password: password,
      role: 'User',
      status: 'active',
    );
  }
}

void main() {
  group('Auth Repository Unit Tests', () {
    late AuthRepositoryImpl repository;

    setUp(() {
      repository = AuthRepositoryImpl(
        database: FakeDatabase(),
        network: FakeNetwork(),
      );
    });

    test('Login should return user when credentials are valid', () async {
      final user = await repository.login('test@example.com', 'password123');

      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
    });

    test('User isAdmin helper works correctly', () {
      const admin = User(
          id: '1',
          name: 'A',
          email: 'e',
          password: 'p',
          role: 'Admin',
          status: 'active');
      const student = User(
          id: '2',
          name: 'S',
          email: 'e',
          password: 'p',
          role: 'User',
          status: 'active');

      expect(admin.isAdmin, isTrue);
      expect(student.isAdmin, isFalse);
    });
  });
}
