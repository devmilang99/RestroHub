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

@Riverpod()
Stream<List<MenuItemModel>> cuisinesStream(Ref ref, String restaurantId) {
  return ref.watch(cuisineRepositoryProvider).watchCuisines(restaurantId);
}

@Riverpod()
Stream<List<MenuItemModel>> allCuisinesStream(Ref ref) {
  return ref.watch(appDatabaseProvider.future).asStream().asyncExpand((db) {
    return db.select(db.cachedMenuItems).watch().asyncMap((list) async {
      return compute(_mapMenuItemRowsToModels, list);
    });
  });
}

@Riverpod()
Future<String?> restaurantIdFromCategory(Ref ref, String categoryId) async {
  final db = await ref.read(appDatabaseProvider.future);
  final query = db.select(db.cachedMenuCategories)
    ..where((t) => t.id.equals(categoryId));
  final row = await query.getSingleOrNull();
  return row?.restaurantId;
}

@Riverpod()
Future<RestaurantModel?> restaurantFromId(Ref ref, String restaurantId) async {
  final db = await ref.read(appDatabaseProvider.future);
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

final restaurantFromCategoryIdProvider =
    FutureProvider.family<RestaurantModel?, String>((ref, categoryId) async {
      final restaurantId = await ref.watch(
        restaurantIdFromCategoryProvider(categoryId).future,
      );
      if (restaurantId == null) return null;
      return ref.watch(restaurantFromIdProvider(restaurantId).future);
    });

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
