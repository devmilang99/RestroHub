import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:riverpod/src/providers/provider.dart';

class FavouritesNotifier extends AsyncNotifier<List<MenuItemModel>> {
  @override
  FutureOr<List<MenuItemModel>> build() async {
    final db = await ref.watch(appDatabaseProvider.future);
    final favs = await db.select(db.cachedFavourites).get();
    return _resolveModels(favs, db);
  }

  Future<List<MenuItemModel>> _resolveModels(
    List<CachedFavourite> favs,
    AppDatabase db,
  ) async {
    final results = <MenuItemModel>[];
    if (favs.isEmpty) return results;

    final restaurantIds = favs
        .where((f) => f.type == 'restaurant')
        .map((f) => f.id)
        .toList();
    final menuItemIds = favs
        .where((f) => f.type == 'menu_item')
        .map((f) => f.id)
        .toList();

    if (restaurantIds.isNotEmpty) {
      final restaurants = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.isIn(restaurantIds))).get();
      for (final r in restaurants) {
        results.add(
          MenuItemModel(
            id: r.id,
            categoryId: '', // dummy
            name: r.name,
            description: r.description ?? '',
            imageUrl: r.logoUrl,
            price: 0,
          ),
        );
      }
    }

    if (menuItemIds.isNotEmpty) {
      final menuItems = await (db.select(
        db.cachedMenuItems,
      )..where((t) => t.id.isIn(menuItemIds))).get();
      for (final c in menuItems) {
        results.add(
          MenuItemModel(
            id: c.id,
            categoryId: c.categoryId,
            name: c.name,
            description: c.description ?? '',
            imageUrl: c.imageUrl,
            price: c.price,
            dietaryFlags: c.dietaryFlags,
          ),
        );
      }
    }

    return results;
  }

  Future<void> toggleFavourite(
    MenuItemModel item, {
    bool isRestaurant = false,
  }) async {
    final db = await ref.read(appDatabaseProvider.future);
    final id = item.id!;

    final existing = await (db.select(
      db.cachedFavourites,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (existing != null) {
      await (db.delete(
        db.cachedFavourites,
      )..where((t) => t.id.equals(id))).go();
    } else {
      await db
          .into(db.cachedFavourites)
          .insert(
            CachedFavouritesCompanion.insert(
              id: id,
              type: isRestaurant ? 'restaurant' : 'menu_item',
            ),
          );
    }

    // Refresh state
    state = await AsyncValue.guard(() async {
      final favs = await db.select(db.cachedFavourites).get();
      return _resolveModels(favs, db);
    });
  }

  bool isFavourite(MenuItemModel item) {
    final id = item.id;
    return state.value?.any(
          (element) => element.id == id,
        ) ??
        false;
  }
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<MenuItemModel>>(() {
      return FavouritesNotifier();
    });

final ProviderFamily<bool, String?> isFavouriteProvider = Provider.family<bool, String?>((ref, id) {
  if (id == null) return false;
  final favourites = ref.watch(favouritesProvider).value ?? [];
  return favourites.any((e) => e.id == id);
});
