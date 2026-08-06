import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

    // Skip if last sync was successful and recent (within 1 minute)
    if (!force && syncState.lastSync != null) {
      final timeSinceLastSync = DateTime.now().difference(syncState.lastSync!);
      if (timeSinceLastSync.inMinutes < 1) {
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
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.05);
      }
    });

    try {
      if (!ref.mounted) return;
      final db = await ref.read(appDatabaseProvider.future);

      if (!ref.mounted) return;

      // 1. Clear local database data and image cache
      logInfo(
        'SYNC: Clearing local restaurant data and cache for a fresh start...',
      );
      await db.clearRestaurantData();
      try {
        await DefaultCacheManager().emptyCache();
      } catch (e) {
        logWarning('SYNC: Failed to clear image cache: $e');
      }

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.1);
      }

      logInfo('SYNC: Fetching restaurants from Supabase...');
      // Fetch from Supabase with deep nesting
      final response = await _client
          .from('restaurants')
          .select('*, menu_categories(*, menu_items(*))');
      final data = response as List<dynamic>;

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.3);
      }

      if (data.isEmpty) {
        logWarning('SYNC: No restaurants found in Supabase.');
        if (ref.mounted) {
          ref.read(globalSyncStatusProvider.notifier).completeSync();
        }
        return;
      }

      logInfo('SYNC: Fetched ${data.length} raw restaurant records.');

      int totalCategories = 0;
      int totalItems = 0;

      for (final rJson in data) {
        final categories = rJson['menu_categories'] as List?;
        if (categories != null) {
          totalCategories += categories.length;
          for (final cJson in categories) {
            final items = cJson['menu_items'] as List?;
            if (items != null) {
              totalItems += items.length;
            }
          }
        }
      }

      logInfo(
        'SYNC DIAGNOSTIC: Found $totalCategories categories and $totalItems items in raw response.',
      );

      if (!ref.mounted) return;

      // Heavy JSON parsing in background isolate
      logInfo('SYNC: Parsing restaurant data in background...');
      final restaurants = await BackgroundWorker.runHeavyTask(
        _parseRestaurants,
        data,
      );

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.5);
      }

      logInfo('SYNC: Parsed ${restaurants.length} restaurants successfully.');

      for (final r in restaurants) {
        logInfo(
          'SYNC DATA: Restaurant "${r.name}" (ID: ${r.id}) -> logo: ${r.logoUrl}, banner: ${r.bannerUrl}',
        );
      }

      if (!ref.mounted) return;

      // Efficient Chunked Batch Insertion to avoid memory spikes and UI lag
      logInfo(
        'SYNC: Starting Drift batch insertion for ${restaurants.length} restaurants...',
      );

      const chunkSize = 20; // Reduced from 50 for smoother UI during sync
      final totalChunks = (restaurants.length / chunkSize).ceil();

      for (var i = 0; i < restaurants.length; i += chunkSize) {
        final currentChunkIdx = i ~/ chunkSize;
        final end = (i + chunkSize < restaurants.length)
            ? i + chunkSize
            : restaurants.length;
        final chunk = restaurants.sublist(i, end);

        logInfo(
          'SYNC: Processing chunk ${currentChunkIdx + 1} of $totalChunks (${chunk.length} items)...',
        );

        // Update progress during insertion (from 0.5 to 0.9)
        if (ref.mounted) {
          final insertionProgress =
              0.5 + (0.4 * (currentChunkIdx / totalChunks));
          ref
              .read(globalSyncStatusProvider.notifier)
              .updateProgress(insertionProgress);
        }

        await db.batch((batch) {
          for (final restaurant in chunk) {
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
                phone: Value(restaurant.phone),
                email: Value(restaurant.email),
                website: Value(restaurant.website),
                status: Value(restaurant.status.toSnakeCase()),
                rating: Value(restaurant.rating),
                priceRange: Value(restaurant.priceRange),
                minOrderAmount: Value(restaurant.minOrderAmount),
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
                    rating: Value(item.rating),
                    dietaryFlags: Value(item.dietaryFlags),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
              }
            }
          }
        });

        // Give breathing room to the event loop between chunks
        await Future<void>.delayed(Duration.zero);
        await Future<void>.microtask(() {}); // Ensure UI events are processed
      }

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.95);
      }

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
      final menuItemId = cartItemJson['menu_item_id'];

      // We use a delete-then-insert pattern to avoid "ON CONFLICT" specification errors
      // if the remote table doesn't have a unique constraint on (user_id, menu_item_id).
      await _client.from('cart_items').delete().match(<String, Object>{
        'user_id': userId,
        'menu_item_id': menuItemId as Object,
      });

      await _client.from('cart_items').insert({
        ...cartItemJson,
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      });
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
      // We use a delete-then-insert pattern to avoid "ON CONFLICT" specification errors
      // if the remote table doesn't have a unique constraint on (user_id, item_id).
      await _client.from('favourites').delete().match({
        'user_id': userId,
        'item_id': itemId,
      });

      await _client.from('favourites').insert({
        'user_id': userId,
        'item_id': itemId,
        'type': type,
      });
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
        await Future<void>.delayed(Duration.zero); // Throttle
      }

      // 2. Export Favourites
      final favRows = await db.select(db.cachedFavourites).get();
      for (final row in favRows) {
        await pushFavourite(row.id, row.type);
        await Future<void>.delayed(Duration.zero);
      }

      // 3. Export Orders
      final orderRows = await db.select(db.cachedOrders).get();
      for (final row in orderRows) {
        final itemRows = await (db.select(
          db.cachedOrderItems,
        )..where((t) => t.orderId.equals(row.id))).get();

        // Offload mapping to background isolate for potential complex order histories
        final payload = await compute(_prepareOrderExportPayload, {
          'order': row,
          'items': itemRows,
        });

        await pushOrderToRemote(
          payload['order'] as Map<String, dynamic>,
          payload['items'] as List<Map<String, dynamic>>,
        );
        await Future<void>.delayed(Duration.zero);
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
      'restaurants',
      'menu_categories',
      'menu_items',
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

          // Deep diagnostic for menu hierarchy
          if (table == 'restaurants') {
            final deepResponse = await _client
                .from('restaurants')
                .select('name, menu_categories(name, menu_items(count))')
                .limit(1);
            logInfo('DIAGNOSTICS: Deep menu hierarchy check: $deepResponse');
          }
        } else {
          logWarning('DIAGNOSTICS: Table "$table" is empty.');
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

/// Top-level function for background mapping of order export payload
Map<String, dynamic> _prepareOrderExportPayload(Map<String, dynamic> params) {
  final row = params['order'] as CachedOrder;
  final itemRows = params['items'] as List<CachedOrderItem>;

  return {
    'order': {
      'id': row.id,
      'restaurant_id': row.restaurantId,
      'status': row.status,
      'total_amount': row.totalAmount,
      'created_at': row.createdAt.toIso8601String(),
      'discount_amount': row.discountAmount,
    },
    'items': itemRows
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
  };
}
