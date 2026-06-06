import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';
import 'package:smart_resources/core/providers.dart';

void main() {
  group('Resource Providers Tests', () {
    test('resourceNotifierProvider should initialize with loading or empty state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(resourceNotifierProvider);
      
      // AsyncNotifier starts in a loading state if not initialized
      expect(state.isLoading, isTrue);
    });

    test('bookmarkedResourcesProvider should be accessible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify the provider exists and is of correct type
      expect(container.read(bookmarkedResourcesProvider), isA<AsyncValue>());
    });
  });
}
