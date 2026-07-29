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

    test('showError updates state correctly', () {
      final notifier = container.read(errorServiceProvider.notifier);
      notifier.showError(message: 'Test error', type: ErrorType.network);

      final state = container.read(errorServiceProvider);
      expect(state, isNotNull);
      expect(state!.message, 'Test error');
      expect(state.type, ErrorType.network);
    });

    test('clearError resets state to null', () {
      final notifier = container.read(errorServiceProvider.notifier);
      notifier.showError(message: 'Error');
      notifier.clearError();

      final state = container.read(errorServiceProvider);
      expect(state, isNull);
    });

    test('handleException parses network error correctly', () {
      final notifier = container.read(errorServiceProvider.notifier);
      notifier.handleException(Exception('SocketException: Connection failed'));

      final state = container.read(errorServiceProvider);
      expect(state!.type, ErrorType.network);
      expect(state.message, contains('internet connection'));
    });
  });
}
