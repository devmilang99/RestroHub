import 'dart:async';

import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/utils/background_worker.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/data/repositories/restaurant_repository.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_provider.g.dart';

@riverpod
class RestaurantFilter extends _$RestaurantFilter {
  @override
  String build() => 'All';

  String get filter => state;
  set filter(String val) => state = val;
}

@riverpod
class RestaurantSearch extends _$RestaurantSearch {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  void setSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = query;
    });
  }
}

@riverpod
Future<void> initialSync(Ref ref) async {
  ref.keepAlive();
  try {
    final syncManager = ref.read(supabaseSyncManagerProvider.notifier);
    await syncManager.syncRestaurants();
  } finally {
    // We can decide to let it stay or close it.
    // For portfolio, keeping it alive for a while is fine.
    // link.close();
  }
}

@riverpod
Stream<List<RestaurantModel>> restaurantsStream(Ref ref) {
  return ref.watch(restaurantRepositoryProvider).watchRestaurants();
}

@riverpod
class FilteredRestaurants extends _$FilteredRestaurants {
  int _page = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<RestaurantModel>> build() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchRestaurants();
  }

  Future<List<RestaurantModel>> _fetchRestaurants() async {
    final filter = ref.watch(restaurantFilterProvider);
    final query = ref.watch(restaurantSearchProvider);

    final repository = ref.read(restaurantRepositoryProvider);
    final result = await repository.getRestaurants(
      limit: _pageSize,
      offset: _page * _pageSize,
    );

    return result.fold(
      onSuccess: (data) {
        if (data.length < _pageSize) {
          _hasMore = false;
        }

        // Apply local filtering/search if repository doesn't handle all complex filters yet
        // In a real app, these would be PRAGMA/WHERE clauses in SQL for efficiency
        return BackgroundWorker.runHeavyTask(_filterRestaurants, {
          'list': data,
          'filter': filter,
          'query': query,
        });
      },
      onFailure: (error) => throw error,
    );
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    // ignore: invalid_use_of_internal_member
    state = AsyncValue<List<RestaurantModel>>.loading().copyWithPrevious(state);

    try {
      _page++;
      final newItems = await _fetchRestaurants();

      final currentItems = state.value ?? [];
      state = AsyncValue.data([...currentItems, ...newItems]);
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// Top-level function for background filtering
List<RestaurantModel> _filterRestaurants(Map<String, dynamic> params) {
  final list = params['list'] as List<RestaurantModel>;
  final filter = params['filter'] as String;
  final query = params['query'] as String;

  var filteredList = list;

  // Filter logic
  if (filter == 'Top Rated') {
    filteredList = filteredList.where((r) => r.rating >= 4.7).toList();
  } else if (filter == 'Open Now') {
    filteredList = filteredList
        .where(
          (r) => r.status == RestaurantStatus.open,
        )
        .toList();
  } else if (filter == 'Cost Effective') {
    filteredList = filteredList.where((r) => r.priceRange.length <= 1).toList();
  } else if (filter == 'Premium') {
    filteredList = filteredList.where((r) => r.priceRange.length >= 3).toList();
  }

  // Search logic
  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    filteredList = filteredList
        .where(
          (r) =>
              r.name.toLowerCase().contains(lowerQuery) ||
              r.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  return filteredList;
}
