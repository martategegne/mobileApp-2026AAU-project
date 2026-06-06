import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/requests/presentation/providers/request_notifier.dart';

void main() {
  group('Request Providers Tests', () {
    test('requestNotifierProvider should start in loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(requestNotifierProvider);

      expect(state.isLoading, isTrue);
    });
  });
}
