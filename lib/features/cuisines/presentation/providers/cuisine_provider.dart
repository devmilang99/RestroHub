import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/features/cuisines/data/repositories/cuisine_repository.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cuisine_provider.g.dart';

@riverpod
Stream<List<MenuItemModel>> cuisinesStream(Ref ref, String restaurantId) {
  return ref.watch(cuisineRepositoryProvider).watchCuisines(restaurantId);
}

@riverpod
Stream<List<MenuItemModel>> allCuisinesStream(Ref ref) {
  return ref.watch(appDatabaseProvider.future).asStream().asyncExpand((db) {
    return db
        .select(db.cachedMenuItems)
        .watch()
        .asyncMap((list) async {
          return compute(_mapMenuItemRowsToModels, list);
        })
        .distinct((prev, next) {
          // Custom equality check to prevent redundant UI updates
          if (prev.length != next.length) return false;
          for (var i = 0; i < prev.length; i++) {
            if (prev[i] != next[i]) return false;
          }
          return true;
        });
  });
}

@riverpod
Future<String?> restaurantIdFromCategory(Ref ref, String categoryId) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final query = db.select(db.cachedMenuCategories)
    ..where((t) => t.id.equals(categoryId));
  final row = await query.getSingleOrNull();
  return row?.restaurantId;
}

@riverpod
Future<RestaurantModel?> restaurantFromId(Ref ref, String restaurantId) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final query = db.select(db.cachedRestaurants)
    ..where((t) => t.id.equals(restaurantId));
  final row = await query.getSingleOrNull();
  if (row == null) return null;

  return RestaurantModel(
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    description: row.description ?? '',
    logoUrl: row.logoUrl,
    bannerUrl: row.bannerUrl,
    status: RestaurantStatus.fromString(row.status),
    rating: row.rating,
    priceRange: row.priceRange,
    taxPercent: row.taxPercent,
    locationAddress: row.locationAddress,
    latitude: row.latitude,
    longitude: row.longitude,
  );
}

@riverpod
Future<RestaurantModel?> restaurantFromCategoryId(
  Ref ref,
  String categoryId,
) async {
  final restaurantId = await ref.watch(
    restaurantIdFromCategoryProvider(categoryId).future,
  );
  if (restaurantId == null) return null;
  return ref.watch(restaurantFromIdProvider(restaurantId).future);
}

List<MenuItemModel> _mapMenuItemRowsToModels(List<CachedMenuItem> rows) {
  return rows
      .map(
        (row) => MenuItemModel(
          id: row.id,
          categoryId: row.categoryId,
          name: row.name,
          description: row.description ?? '',
          imageUrl: row.imageUrl,
          price: row.price,
          isAvailable: row.isAvailable,
          calories: row.calories,
          dietaryFlags: row.dietaryFlags,
        ),
      )
      .toList();
}

@riverpod
class FilteredCuisines extends _$FilteredCuisines {
  int _page = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<MenuItemModel>> build() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchCuisines();
  }

  Future<List<MenuItemModel>> _fetchCuisines() async {
    final db = await ref.read(appDatabaseProvider.future);
    final query = db.select(db.cachedMenuItems)
      ..limit(_pageSize, offset: _page * _pageSize);
    final rows = await query.get();

    if (rows.length < _pageSize) {
      _hasMore = false;
    }

    return compute(_mapMenuItemRowsToModels, rows);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    final previousState = state;
    try {
      _page++;
      final next = await _fetchCuisines();
      final current = previousState.value ?? [];
      state = AsyncValue.data([...current, ...next]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }
}

// Manual provider to avoid build_runner delays for dashboard integration
final dashboardOffersProvider = FutureProvider<List<MenuItemModel>>((
  ref,
) async {
  final allCuisines = await ref.watch(allCuisinesStreamProvider.future);
  // Filter for hot deals (e.g., price < 500)
  return allCuisines.where((c) => c.price < 500).take(5).toList();
});
