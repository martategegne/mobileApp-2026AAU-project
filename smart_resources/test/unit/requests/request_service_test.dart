import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/requests/data/repositories/request_repository_impl.dart';
import 'package:smart_resources/features/requests/data/models/request_model.dart';
import 'package:smart_resources/core/database/app_database.dart';
import 'package:smart_resources/core/network/network_service.dart';

class FakeDatabase extends Fake implements AppDatabase {
  @override
  Future<List<Map<String, Object?>>> query(String table, {String? where, List<Object?>? whereArgs, bool? distinct, List<String>? columns, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async => [];
  @override
  Future<int> insert(String table, Map<String, Object?> values) async => 1;
}

class FakeNetwork extends Fake implements NetworkService {
  @override
  Future<List<RequestModel>> fetchRequests() async => [
    RequestModel(id: '1', title: 'Request 1', description: 'D1', courseCode: 'C1', requestedBy: 'User', time: DateTime.now().toString(), status: 'open')
  ];
}

void main() {
  group('Request Repository Unit Tests', () {
    late RequestRepositoryImpl repository;

    setUp(() {
      repository = RequestRepositoryImpl(
        database: FakeDatabase(),
        network: FakeNetwork(),
      );
    });

    test('getRequests should fetch from network if local is empty', () async {
      final requests = await repository.getRequests();
      expect(requests, isNotEmpty);
      expect(requests.first.title, equals('Request 1'));
    });
  });
}
