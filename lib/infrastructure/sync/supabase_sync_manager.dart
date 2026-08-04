import 'dart:async';

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

  User? get currentUser => _client.auth.currentUser;

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
          'SYNC DIAGNOSTIC: Raw sample keys: ${(data.first as Map).keys.toList()}',
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
      unawaited(
        Future.microtask(() {
          if (ref.mounted) {
            ref.read(globalSyncStatusProvider.notifier).completeSync();
          }
        }),
      );
    } on Object catch (e, stack) {
      logError('SYNC ERROR: Detailed failure report', e, stack);
      unawaited(
        Future.microtask(() {
          if (ref.mounted) {
            final errorMsg = e.toString();
            ref.read(globalSyncStatusProvider.notifier).failSync(errorMsg);
          }
        }),
      );
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

  /// Pushes a new order and its items to Supabase
  Future<void> pushOrderToRemote(
    Map<String, dynamic> orderJson,
    List<Map<String, dynamic>> itemsJson,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      logWarning(
        'SYNC: Cannot push order ${orderJson['id']} to remote - No authenticated user found.',
      );
      return;
    }

    try {
      // Use upsert for orders to avoid duplicate key errors if sync is retried
      await _client.from('orders').upsert({
        ...orderJson,
        'customer_id': userId,
      });

      if (itemsJson.isNotEmpty) {
        // For order items, we use upsert matching on the primary key or unique identifier
        await _client
            .from('order_items')
            .upsert(
              itemsJson
                  .map(
                    (item) => {
                      ...item,
                      'order_id': orderJson['id'],
                    },
                  )
                  .toList(),
            );
      }
    } on PostgrestException catch (e) {
      logError(
        'SYNC ERROR: Supabase Database Error in pushOrderToRemote',
        'Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
      );
    } on Object catch (e) {
      logError('SYNC ERROR: Unexpected failure in pushOrderToRemote', e);
    }
  }

  /// Fetches orders and their items from Supabase for the current user
  Future<List<Map<String, dynamic>>> fetchRemoteOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on Object catch (e) {
      logError('SYNC ERROR: Failed to fetch orders from Supabase', e);
      return [];
    }
  }

  /// Syncs local cart items to Supabase
  Future<void> pushCartItem(Map<String, dynamic> cartItemJson) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Specify onConflict to ensure it updates existing items for this user
      await _client.from('cart_items').upsert(
        {
          ...cartItemJson,
          'user_id': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, menu_item_id',
      );
    } on PostgrestException catch (e) {
      logError(
        'SYNC ERROR: Supabase Database Error in pushCartItem',
        'Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
      );
    }
  }

  /// Removes a cart item from Supabase
  Future<void> removeCartItem(String menuItemId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('cart_items').delete().match({
      'user_id': userId,
      'menu_item_id': menuItemId,
    });
  }

  /// Fetches the user's cart from Supabase
  Future<List<Map<String, dynamic>>> fetchRemoteCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('cart_items')
        .select('*')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Clears user cart in Supabase
  Future<void> clearRemoteCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('cart_items').delete().eq('user_id', userId);
  }

  /// Generic remote sync helper
  Future<void> syncLocalToRemote(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      await _client.from(table).upsert(data);
    } on PostgrestException catch (e) {
      logError(
        'SYNC ERROR: Supabase Database Error in syncLocalToRemote ($table)',
        'Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
      );
    }
  }

  /// Pushes a favorite to Supabase
  Future<void> pushFavourite(String itemId, String type) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('favourites').upsert(
        {
          'user_id': userId,
          'item_id': itemId,
          'type': type,
        },
        onConflict: 'user_id, item_id',
      );
    } on PostgrestException catch (e) {
      logError('SYNC ERROR: Failed to push favourite', e.message);
    }
  }

  /// Removes a favorite from Supabase
  Future<void> removeFavourite(String itemId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('favourites').delete().match({
        'user_id': userId,
        'item_id': itemId,
      });
    } on PostgrestException catch (e) {
      logError('SYNC ERROR: Failed to remove favourite', e.message);
    }
  }

  /// Pushes a transaction record to Supabase
  Future<void> pushTransaction(Map<String, dynamic> transactionData) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('transactions').upsert({
        ...transactionData,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      logError('SYNC ERROR: Failed to push transaction', e.message);
    }
  }

  /// Forces a full sync of all local data to Supabase
  Future<void> performFullExport() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      logError('SYNC: Cannot export data - No authenticated user found.');
      return;
    }

    logInfo('SYNC: Starting full data export to Supabase...');
    final db = await ref.read(appDatabaseProvider.future);

    try {
      // 1. Export Cart
      final cartRows = await db.select(db.cachedCartItems).get();
      for (final row in cartRows) {
        await pushCartItem({
          'menu_item_id': row.menuItemId,
          'restaurant_id': row.restaurantId,
          'name': row.name,
          'price_at_purchase': row.price,
          'image_url': row.imageUrl,
          'quantity': row.quantity,
        });
      }

      // 2. Export Favourites
      final favRows = await db.select(db.cachedFavourites).get();
      for (final row in favRows) {
        await pushFavourite(row.id, row.type);
      }

      // 3. Export Orders
      final orderRows = await db.select(db.cachedOrders).get();
      for (final row in orderRows) {
        final itemRows = await (db.select(
          db.cachedOrderItems,
        )..where((t) => t.orderId.equals(row.id))).get();

        await pushOrderToRemote(
          {
            'id': row.id,
            'restaurant_id': row.restaurantId,
            'status': row.status,
            'total_amount': row.totalAmount,
            'created_at': row.createdAt.toIso8601String(),
            'discount_amount': row.discountAmount,
          },
          itemRows
              .map(
                (i) => {
                  'menu_item_id': i.menuItemId,
                  'name': i.name,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                  'total_price': i.totalPrice,
                },
              )
              .toList(),
        );
      }

      logInfo('SYNC COMPLETE: Full export finished successfully.');
    } catch (e) {
      logError('SYNC ERROR: Bulk export failed', e);
      rethrow;
    }
  }

  /// Diagnoses schema mismatches for critical tables
  Future<void> diagnoseSchemaMismatch() async {
    final tables = [
      'orders',
      'order_items',
      'cart_items',
      'favourites',
      'transactions',
    ];
    logInfo('DIAGNOSTICS: Starting Supabase schema validation...');

    for (final table in tables) {
      try {
        // Try to fetch one row to see if the table exists and columns match
        final response = await _client.from(table).select().limit(1);
        logInfo('DIAGNOSTICS: Table "$table" is accessible.');

        if (response.isNotEmpty) {
          final keys = (response.first as Map).keys.toList();
          logInfo('DIAGNOSTICS: Table "$table" sample keys: $keys');
        }
      } on PostgrestException catch (e) {
        logError(
          'DIAGNOSTICS FAILURE: Table "$table" has issues',
          'Code: ${e.code}, Message: ${e.message}',
        );
      } catch (e) {
        logError('DIAGNOSTICS FAILURE: Unexpected error on table "$table"', e);
      }
    }
  }
}

/// Top-level function for background parsing
List<RestaurantModel> _parseRestaurants(List<dynamic> data) {
  return data
      .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
      .toList();
}
