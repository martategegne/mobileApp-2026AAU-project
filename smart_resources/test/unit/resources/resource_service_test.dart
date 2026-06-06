import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:smart_resources/features/resources/data/models/resource_model.dart';
import 'package:smart_resources/core/database/app_database.dart';
import 'package:smart_resources/core/network/network_service.dart';

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
  Future<List<ResourceModel>> fetchResources() async => [
        const ResourceModel(
            id: '1',
            title: 'Test 1',
            description: 'D1',
            courseCode: 'C1',
            rating: 0,
            reviewCount: 0,
            uses: 0,
            fileType: 'pdf',
            uploader: 'Admin',
            isApproved: true,
            isBookmarked: false,
            isDownloaded: false)
      ];
}

void main() {
  group('Resource Repository Unit Tests', () {
    late ResourceRepositoryImpl repository;

    setUp(() {
      repository = ResourceRepositoryImpl(
        database: FakeDatabase(),
        network: FakeNetwork(),
      );
    });

    test('getResources should fetch from network if local is empty', () async {
      final resources = await repository.getResources();
      expect(resources, isNotEmpty);
      expect(resources.first.title, equals('Test 1'));
    });
  });
}
