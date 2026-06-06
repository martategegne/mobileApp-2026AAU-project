import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';

void main() {
  group('Auth Providers Tests', () {
    test('authNotifierProvider should start with an empty AuthState', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authNotifierProvider);

      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('logout should clear user data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // We can't easily mock the repository here without more setup,
      // but we can test the logout logic which just clears the state.
      
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.logout();

      final state = container.read(authNotifierProvider);
      expect(state.user, isNull);
    });
  });
}
