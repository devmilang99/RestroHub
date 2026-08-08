import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/features/favourites/data/models/favourite_item.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:riverpod/src/providers/provider.dart';

class FavouritesNotifier extends AsyncNotifier<List<FavouriteItem>> {
  @override
  FutureOr<List<FavouriteItem>> build() async {
    logInfo('FAV_PROVIDER: Building FavouritesNotifier...');

    // 1. Watch current user to ensure data isolation and resets on logout/login
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    if (user == null) {
      logInfo('FAV_PROVIDER: No user logged in, returning empty list.');
      return [];
    }

    // 2. Watch raw favorites stream from DB
    // This ensures FavouritesNotifier automatically rebuilds when Supabase sync updates the local DB
    final db = await ref.watch(appDatabaseProvider.future);
    final rawFavs = ref.watch(rawFavouritesStreamProvider).value ?? [];

    logInfo(
      'FAV_PROVIDER: DB update detected (${rawFavs.length} items for ${user.id}). Resolving models...',
    );

    return _resolveModels(rawFavs, db);
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
      final query = db.select(db.cachedMenuItems).join([
        leftOuterJoin(
          db.cachedMenuCategories,
          db.cachedMenuCategories.id.equalsExp(db.cachedMenuItems.categoryId),
        ),
        leftOuterJoin(
          db.cachedRestaurants,
          db.cachedRestaurants.id.equalsExp(
            db.cachedMenuCategories.restaurantId,
          ),
        ),
      ])..where(db.cachedMenuItems.id.isIn(menuItemIds));

      final rows = await query.get();
      logInfo('FAV_PROVIDER: Found ${rows.length} matching menu items in DB.');

      for (final row in rows) {
        final c = row.readTable(db.cachedMenuItems);
        final r = row.readTableOrNull(db.cachedRestaurants);

        RestaurantModel? restaurant;
        if (r != null) {
          restaurant = RestaurantModel(
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
          );
        }

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
            restaurant: restaurant,
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

/// A stream provider that watches the raw favorites in the local DB.
/// This is used by [FavouritesNotifier] to react to background sync updates.
final rawFavouritesStreamProvider = StreamProvider<List<CachedFavourite>>((
  ref,
) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  yield* db.select(db.cachedFavourites).watch();
});

final ProviderFamily<bool, String?> isFavouriteProvider =
    Provider.family<bool, String?>((ref, id) {
      if (id == null) return false;
      final favourites = ref.watch(favouritesProvider).value ?? [];
      return favourites.any((e) => e.id == id);
    });
