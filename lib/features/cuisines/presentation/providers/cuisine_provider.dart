import 'package:flutter/foundation.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:restro_hub/features/cuisines/data/repositories/cuisine_repository.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cuisine_provider.g.dart';

@riverpod
Stream<List<MenuItemModel>> cuisinesStream(Ref ref, String restaurantId) {
  return ref.watch(cuisineRepositoryProvider).watchCuisines(restaurantId);
}

@riverpod
Stream<List<MenuItemModel>> allCuisinesStream(Ref ref) {
  return ref.watch(appDatabaseProvider.future).asStream().asyncExpand((
    db,
  ) {
    return db.select(db.cachedMenuItems).watch().asyncMap((list) async {
      final models = await compute(_mapMenuItemRowsToModels, list);
      return models;
    });
  });
}

/// Top-level function for background mapping
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
