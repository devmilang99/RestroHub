import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restro_hub/core/providers/error_service.dart';

void main() {
  group('ErrorService Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is null', () {
      final state = container.read(errorServiceProvider);
      expect(state, isNull);
    });

    test('showError updates state correctly', () async {
      final notifier = container.read(errorServiceProvider.notifier);
      // ignore: cascade_invocations
      notifier.showError(message: 'Test error', type: ErrorType.network);

      // Wait for the microtask to complete
      await Future.microtask(() {});

      final state = container.read(errorServiceProvider);
      expect(state, isNotNull);
      expect(state!.message, 'Test error');
      expect(state.type, ErrorType.network);
    });

    test('clearError resets state to null', () async {
      final notifier = container.read(errorServiceProvider.notifier);
      // ignore: cascade_invocations
      notifier.showError(message: 'Error');
      
      await Future.microtask(() {});
      expect(container.read(errorServiceProvider), isNotNull);

      // ignore: cascade_invocations
      notifier.clearError();
      await Future.microtask(() {});

      final state = container.read(errorServiceProvider);
      expect(state, isNull);
    });

    test('handleException parses network error correctly', () async {
      final notifier = container.read(errorServiceProvider.notifier);
      // ignore: cascade_invocations
      notifier.handleException(
        Exception('SocketException: Connection failed'),
      );

      await Future.microtask(() {});

      final state = container.read(errorServiceProvider);
      expect(state!.type, ErrorType.network);
      expect(state.message, contains('internet connection'));
    });
  });
}
