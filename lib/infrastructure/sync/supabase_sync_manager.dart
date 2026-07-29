import 'package:drift/drift.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/utils/background_worker.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';
import 'package:restro_hub/infrastructure/sync/models/sync_status.dart';
import 'package:restro_hub/infrastructure/sync/sync_monitor_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_sync_manager.g.dart';

@Riverpod(keepAlive: true)
class SupabaseSyncManager extends _$SupabaseSyncManager {
  late final SupabaseClient _client;

  @override
  void build() {
    _client = ref.watch(supabaseClientProvider);
  }

  /// Initiates a background sync of restaurants, categories, and items into Drift.
  Future<void> syncRestaurants({bool force = false}) async {
    final syncState = ref.read(globalSyncStatusProvider);

    if (syncState.status == SyncStatus.syncing) {
      logInfo('SYNC: Sync already in progress, skipping...');
      return;
    }

    // Skip if last sync was successful and recent (within 5 minutes)
    if (!force && syncState.lastSync != null) {
      final timeSinceLastSync = DateTime.now().difference(syncState.lastSync!);
      if (timeSinceLastSync.inMinutes < 5) {
        logInfo(
          'SYNC: Data is fresh (last synced ${timeSinceLastSync.inMinutes}m ago). Skipping...',
        );
        return;
      }
    }

    logInfo('SYNC: Starting restaurant synchronization...');
    await Future.microtask(() {
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).startSync();
      }
    });

    try {
      if (!ref.mounted) return;
      final db = await ref.read(appDatabaseProvider.future);

      if (!ref.mounted) return;

      logInfo('SYNC: Fetching restaurants from Supabase...');
      // Fetch from Supabase with deep nesting
      final response = await _client
          .from('restaurants')
          .select('*, menu_categories(*, menu_items(*))');
      final data = response as List<dynamic>;

      if (data.isEmpty) {
        logWarning('SYNC: No restaurants found in Supabase.');
        return;
      }

      logInfo('SYNC: Fetched ${data.length} raw restaurant records.');

      if (data.isNotEmpty) {
        logInfo(
          'SYNC DIAGNOSTIC: Raw sample keys: ${data.first.keys.toList()}',
        );
      }

      if (!ref.mounted) return;

      // Heavy JSON parsing in background isolate
      logInfo('SYNC: Parsing restaurant data in background...');
      final restaurants = await BackgroundWorker.runHeavyTask(
        _parseRestaurants,
        data,
      );

      logInfo('SYNC: Parsed ${restaurants.length} restaurants successfully.');

      if (!ref.mounted) return;

      // Efficient Batch Insertion
      logInfo(
        'SYNC: Starting Drift batch insertion for ${restaurants.length} restaurants...',
      );

      await db.batch((batch) {
        for (final restaurant in restaurants) {
          if (restaurant.id == null || restaurant.id!.isEmpty) continue;

          // Insert Restaurant
          batch.insert(
            db.cachedRestaurants,
            CachedRestaurantsCompanion(
              id: Value(restaurant.id!),
              ownerId: Value(restaurant.ownerId),
              name: Value(restaurant.name),
              description: Value(restaurant.description),
              logoUrl: Value(restaurant.logoUrl),
              bannerUrl: Value(restaurant.bannerUrl),
              status: Value(restaurant.status.toSnakeCase()),
              rating: Value(restaurant.rating),
              priceRange: Value(restaurant.priceRange),
              taxPercent: Value(restaurant.taxPercent),
              locationAddress: Value(restaurant.locationAddress),
              latitude: Value(restaurant.latitude),
              longitude: Value(restaurant.longitude),
            ),
            mode: InsertMode.insertOrReplace,
          );

          // Insert Categories
          for (final category in restaurant.categories) {
            if (category.id == null || category.id!.isEmpty) continue;

            batch.insert(
              db.cachedMenuCategories,
              CachedMenuCategoriesCompanion(
                id: Value(category.id!),
                restaurantId: Value(restaurant.id!),
                name: Value(category.name),
                priority: Value(category.priority),
              ),
              mode: InsertMode.insertOrReplace,
            );

            // Insert Items
            for (final item in category.items) {
              if (item.id == null || item.id!.isEmpty) continue;

              batch.insert(
                db.cachedMenuItems,
                CachedMenuItemsCompanion(
                  id: Value(item.id!),
                  categoryId: Value(category.id!),
                  name: Value(item.name),
                  price: Value(item.price),
                  description: Value(item.description),
                  imageUrl: Value(item.imageUrl),
                  isAvailable: Value(item.isAvailable),
                  calories: Value(item.calories),
                  dietaryFlags: Value(item.dietaryFlags),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });

      logInfo('SYNC COMPLETE: Batch insertion finished successfully.');

      // Verify insertion by counting rows (optional debug check)
      final restCount = await (db.select(db.cachedRestaurants)..limit(1)).get();
      logInfo(
        'SYNC: Verification check - DB has ${restCount.length} sample restaurant row.',
      );

      // Update sync metadata
      await db
          .into(db.syncMetadata)
          .insert(
            SyncMetadataCompanion.insert(
              tableIdentifier: 'restaurants',
              lastSync: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );

      logInfo('SYNC: Successfully completed restaurant sync.');
      Future.microtask(() {
        if (ref.mounted) {
          ref.read(globalSyncStatusProvider.notifier).completeSync();
        }
      });
    } catch (e, stack) {
      logError('SYNC ERROR: Detailed failure report', e, stack);
      Future.microtask(() {
        if (ref.mounted) {
          final errorMsg = e.toString();
          ref.read(globalSyncStatusProvider.notifier).failSync(errorMsg);
        }
      });
      if (ref.mounted) {
        ref.read(errorServiceProvider.notifier).handleException(e, stack);
      }
    }
  }

  /// Pushes local profile updates to Supabase
  Future<void> syncProfile(Map<String, dynamic> profileData) async {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('profiles').upsert({
        'id': userId,
        ...profileData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Generic remote sync helper
  Future<void> syncLocalToRemote(
    String table,
    Map<String, dynamic> data,
  ) async {
    await _client.from(table).upsert(data);
  }
}

/// Top-level function for background parsing
List<RestaurantModel> _parseRestaurants(List<dynamic> data) {
  return data
      .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
      .toList();
}
