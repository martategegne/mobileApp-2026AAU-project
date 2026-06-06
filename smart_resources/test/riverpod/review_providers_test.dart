import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';
import 'package:smart_resources/core/providers.dart';
import 'package:smart_resources/features/resources/domain/entities/review.dart';
import 'package:smart_resources/features/resources/domain/repositories/resource_repository.dart';

class FakeResourceRepository extends Fake implements ResourceRepository {
  @override
  Future<List<Review>> getReviewsForResource(String resourceId) async => [];
}

void main() {
  group('Review Providers Tests', () {
    test('resourceReviewsProvider should start in loading state', () {
      final container = ProviderContainer(overrides: [
        resourceRepositoryProvider.overrideWithValue(FakeResourceRepository()),
      ]);
      addTearDown(container.dispose);

      final state = container.read(resourceReviewsProvider('res-1'));

      expect(state.isLoading, isTrue);
    });

    test('resourceReviewsProvider should return a list after loading', () async {
      final container = ProviderContainer(overrides: [
        resourceRepositoryProvider.overrideWithValue(FakeResourceRepository()),
      ]);
      addTearDown(container.dispose);

      final reviews = await container.read(resourceReviewsProvider('res-1').future);
      expect(reviews, isA<List<Review>>());
    });
  });
}
