import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/favourites/data/models/favourite_item.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:riverpod/src/providers/provider.dart';

class FavouritesNotifier extends AsyncNotifier<List<FavouriteItem>> {
  @override
  FutureOr<List<FavouriteItem>> build() async {
    logInfo('FAV_PROVIDER: Building FavouritesNotifier...');
    final db = await ref.watch(appDatabaseProvider.future);
    logInfo('FAV_PROVIDER: Fetching raw favorites from DB...');
    final favs = await db.select(db.cachedFavourites).get();
    logInfo(
      'FAV_PROVIDER: Found ${favs.length} raw favorites. Resolving models...',
    );
    return _resolveModels(favs, db);
  }

  Future<List<FavouriteItem>> _resolveModels(
    List<CachedFavourite> favs,
    AppDatabase db,
  ) async {
    final results = <FavouriteItem>[];
    if (favs.isEmpty) {
      logInfo('FAV_PROVIDER: No favorites to resolve.');
      return results;
    }

    final restaurantIds = favs
        .where((f) => f.type == 'restaurant')
        .map((f) => f.id)
        .toList();
    logInfo(
      'FAV_PROVIDER: Found ${restaurantIds.length} restaurant IDs to resolve.',
    );
    final menuItemIds = favs
        .where((f) => f.type == 'menu_item')
        .map((f) => f.id)
        .toList();

    if (restaurantIds.isNotEmpty) {
      logInfo('FAV_PROVIDER: Querying restaurants for IDs: $restaurantIds');
      final restaurants = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.isIn(restaurantIds))).get();
      logInfo(
        'FAV_PROVIDER: Found ${restaurants.length} matching restaurants in DB.',
      );
      for (final r in restaurants) {
        results.add(
          RestaurantFavourite(
            RestaurantModel(
              id: r.id,
              ownerId: r.ownerId,
              name: r.name,
              description: r.description ?? '',
              logoUrl: r.logoUrl,
              bannerUrl: r.bannerUrl,
              phone: r.phone,
              email: r.email,
              website: r.website,
              status: RestaurantStatus.fromString(r.status),
              rating: r.rating,
              priceRange: r.priceRange,
              minOrderAmount: r.minOrderAmount,
              taxPercent: r.taxPercent,
              locationAddress: r.locationAddress,
              latitude: r.latitude,
              longitude: r.longitude,
            ),
          ),
        );
      }
    }

    if (menuItemIds.isNotEmpty) {
      logInfo('FAV_PROVIDER: Querying menu items for IDs: $menuItemIds');
      final menuItems = await (db.select(
        db.cachedMenuItems,
      )..where((t) => t.id.isIn(menuItemIds))).get();
      logInfo(
        'FAV_PROVIDER: Found ${menuItems.length} matching menu items in DB.',
      );
      for (final c in menuItems) {
        results.add(
          MenuItemFavourite(
            MenuItemModel(
              id: c.id,
              categoryId: c.categoryId,
              name: c.name,
              description: c.description ?? '',
              imageUrl: c.imageUrl,
              price: c.price,
              dietaryFlags: c.dietaryFlags,
              rating: c.rating ?? 4.5,
              calories: c.calories,
              isAvailable: c.isAvailable,
            ),
          ),
        );
      }
    }

    return results;
  }

  Future<void> toggleFavourite(
    dynamic item, {
    bool isRestaurant = false,
  }) async {
    final db = await ref.read(appDatabaseProvider.future);
    final String id;
    final String type;

    if (item is FavouriteItem) {
      id = item.id;
      type = item is RestaurantFavourite ? 'restaurant' : 'menu_item';
    } else if (item is MenuItemModel) {
      if (item.id == null) return;
      id = item.id!;
      type = isRestaurant ? 'restaurant' : 'menu_item';
    } else if (item is RestaurantModel) {
      if (item.id == null) return;
      id = item.id!;
      type = 'restaurant';
    } else {
      throw ArgumentError('Invalid item type for toggleFavourite');
    }

    final existing = await (db.select(
      db.cachedFavourites,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (existing != null) {
      await (db.delete(
        db.cachedFavourites,
      )..where((t) => t.id.equals(id))).go();

      // Sync to Supabase
      unawaited(
        ref.read(supabaseSyncManagerProvider.notifier).removeFavourite(id),
      );
    } else {
      await db
          .into(db.cachedFavourites)
          .insert(
            CachedFavouritesCompanion.insert(
              id: id,
              type: type,
            ),
          );

      // Sync to Supabase
      unawaited(
        ref.read(supabaseSyncManagerProvider.notifier).pushFavourite(id, type),
      );
    }

    // Refresh state
    state = await AsyncValue.guard(() async {
      final favs = await db.select(db.cachedFavourites).get();
      return _resolveModels(favs, db);
    });
  }

  bool isFavourite(dynamic item) {
    final String? id;
    if (item is FavouriteItem) {
      id = item.id;
    } else if (item is MenuItemModel) {
      id = item.id;
    } else if (item is RestaurantModel) {
      id = item.id;
    } else {
      return false;
    }

    return state.value?.any(
          (element) => element.id == id,
        ) ??
        false;
  }
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<FavouriteItem>>(() {
      return FavouritesNotifier();
    });

final ProviderFamily<bool, String?> isFavouriteProvider =
    Provider.family<bool, String?>((ref, id) {
      if (id == null) return false;
      final favourites = ref.watch(favouritesProvider).value ?? [];
      return favourites.any((e) => e.id == id);
    });
