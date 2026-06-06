import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';

void main() {
  group('Bookmark Providers Tests', () {
    test('bookmarkedResourcesProvider should start in loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(bookmarkedResourcesProvider);

      expect(state.isLoading, isTrue);
    });

    test('bookmarkedResourcesProvider should eventually return a list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // We wait for the provider to initialize (it will be empty because of no user by default in tests)
      final bookmarks = await container.read(bookmarkedResourcesProvider.future);
      expect(bookmarks, isA<List>());
    });
  });
}
