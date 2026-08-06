import 'package:restro_hub/core/models/result.dart';
import 'package:restro_hub/core/utils/app_exception.dart';
import 'package:restro_hub/core/utils/logger.dart';

/// Base Repository implementing the 'Cache-First' strategy for offline-first support.
///
/// It coordinates between local database (Drift) and remote API (Supabase).
abstract class BaseRepository {
  /// Fetches data with a cache-first strategy.
  ///
  /// 1. Immediately emits data from [fromCache] if available.
  /// 2. Fetches fresh data from [fromNetwork].
  /// 3. Persists fresh data to [toCache].
  /// 4. Emits fresh data from network.
  Stream<Result<T>> cacheFirstFetch<T>({
    required Future<T?> Function() fromCache,
    required Future<T> Function() fromNetwork,
    required Future<void> Function(T data) toCache,
  }) async* {
    // 1. Try Cache
    try {
      final cached = await fromCache();
      if (cached != null) {
        yield Success(cached);
      }
    } on Exception catch (e) {
      logError('Cache Fetch Error', e);
    }

    // 2. Try Network
    try {
      final fresh = await fromNetwork();
      // 3. Update Cache
      await toCache(fresh);
      // 4. Yield fresh data
      yield Success(fresh);
    } on AppException catch (e) {
      logError('Network Fetch Error', e);
      yield Failure(e);
    } on Exception catch (e) {
      logError('Network Fetch Unknown Error', e);
      yield Failure(ServerException(e.toString()));
    } on Object catch (e) {
      logError('Network Fetch Unknown Error', e);
      yield Failure(ServerException(e.toString()));
    }
  }
}
