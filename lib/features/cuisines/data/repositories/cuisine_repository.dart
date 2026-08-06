import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cuisine_repository.g.dart';

abstract class ICuisineRepository {
  Stream<List<MenuItemModel>> watchCuisines(String restaurantId);
  Future<List<MenuItemModel>> getCuisines(String restaurantId);
}

class CuisineRepositoryImpl implements ICuisineRepository {
  final Ref _ref;

  CuisineRepositoryImpl(this._ref);

  @override
  Stream<List<MenuItemModel>> watchCuisines(String restaurantId) {
    return Stream.fromFuture(_ref.read(appDatabaseProvider.future)).asyncExpand(
      (db) {
        final query = db.select(db.cachedMenuItems).join([
          innerJoin(
            db.cachedMenuCategories,
            db.cachedMenuCategories.id.equalsExp(db.cachedMenuItems.categoryId),
          ),
        ])..where(db.cachedMenuCategories.restaurantId.equals(restaurantId));

        return query.watch().asyncMap<List<MenuItemModel>>((rows) async {
          // Offload mapping to background isolate for potential large menu lists
          final items = rows
              .map((row) => row.readTable(db.cachedMenuItems))
              .toList();
          return compute<List<CachedMenuItem>, List<MenuItemModel>>(
            _mapRowsToModels,
            items,
          );
        }).distinct(); // Prevent redundant UI updates if data hasn't changed
      },
    );
  }

  @override
  Future<List<MenuItemModel>> getCuisines(String restaurantId) async {
    final db = await _ref.read(appDatabaseProvider.future);
    final query = db.select(db.cachedMenuItems).join([
      innerJoin(
        db.cachedMenuCategories,
        db.cachedMenuCategories.id.equalsExp(db.cachedMenuItems.categoryId),
      ),
    ])..where(db.cachedMenuCategories.restaurantId.equals(restaurantId));

    final rows = await query.get();
    return compute(
      _mapRowsToModels,
      rows.map((row) => row.readTable(db.cachedMenuItems)).toList(),
    );
  }
}

/// Top-level function for background mapping
List<MenuItemModel> _mapRowsToModels(List<CachedMenuItem> rows) {
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
          rating: row.rating ?? 4.5,
          dietaryFlags: row.dietaryFlags,
        ),
      )
      .toList();
}

@riverpod
ICuisineRepository cuisineRepository(Ref ref) {
  return CuisineRepositoryImpl(ref);
}
