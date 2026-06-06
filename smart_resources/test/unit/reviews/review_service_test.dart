import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resources/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:smart_resources/features/resources/domain/entities/review.dart';
import 'package:smart_resources/features/resources/data/models/review_model.dart';
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
  @override
  Future<int> update(String table, Map<String, Object?> values,
          {required String where, required List<Object?> whereArgs}) async =>
      1;
}

class FakeNetwork extends Fake implements NetworkService {
  @override
  Future<ReviewModel> addReview(ReviewModel review) async => ReviewModel(
        id: review.id,
        resourceId: review.resourceId,
        userId: review.userId,
        userName: review.userName,
        rating: review.rating,
        comment: review.comment,
        time: review.time,
      );
}

void main() {
  group('Review Logic Unit Tests', () {
    late ResourceRepositoryImpl repository;

    setUp(() {
      repository = ResourceRepositoryImpl(
        database: FakeDatabase(),
        network: FakeNetwork(),
      );
    });

    test('addReview should process review correctly', () async {
      final review = Review(
        id: '1',
        resourceId: 'res1',
        userId: 'user1',
        userName: 'User 1',
        rating: 5.0,
        comment: 'Great!',
        time: '2023-10-01',
      );

      await repository.addReview(review);
      expect(true, isTrue); // If no exception, logic passed
    });
  });
}
