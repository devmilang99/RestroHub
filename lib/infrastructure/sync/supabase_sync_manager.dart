import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/models/result.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/utils/app_exception.dart';
import 'package:restro_hub/core/utils/background_worker.dart';
import 'package:restro_hub/core/utils/image_utils.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';
import 'package:restro_hub/infrastructure/sync/models/sync_status.dart';
import 'package:restro_hub/infrastructure/sync/sync_monitor_provider.dart';
import 'package:restro_hub/router/router_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

part 'supabase_sync_manager.g.dart';

@Riverpod(keepAlive: true)
class SupabaseSyncManager extends _$SupabaseSyncManager {
  late final SupabaseClient _client;

  @override
  void build() {
    _client = ref.watch(supabaseClientProvider);
  }

  User? get currentUser => _client.auth.currentUser;

  /// Runs all core sync tasks concurrently for maximum efficiency during startup.
  /// Modified to use a phased approach:
  /// 1. Metadata only (Restaurants, Orders, Cart, Favs) for fast splash transition.
  /// 2. Detailed hierarchy (Menu Categories, Items) in the background.
  Future<void> syncAllInitialData({bool metadataOnly = true}) async {
    logInfo(
      'SYNC: Initiating concurrent global synchronization (metadataOnly: $metadataOnly)...',
    );

    // Fire all sync tasks in parallel to saturate the network and IO pipes
    final results = await Future.wait([
      syncRestaurants(force: false, metadataOnly: metadataOnly),
      syncRemoteOrders(),
      syncRemoteCart(),
      syncRemoteFavourites(),
    ]);

    // Log summarizing the results of parallel syncs
    final failures = results.where((r) => r.isFailure).length;
    if (failures > 0) {
      logWarning(
        'SYNC: Phased global synchronization completed with $failures failures.',
      );
    } else {
      logInfo('SYNC: Phased global synchronization completed successfully.');
    }

    // If we just finished metadata, trigger the detailed sync in background
    if (metadataOnly) {
      unawaited(syncDetailedHierarchy());
    }
  }

  /// Initiates a background sync of restaurants, categories, and items into Drift.
  Future<Result<void>> syncRestaurants({
    bool force = false,
    bool clearCache = false,
    bool metadataOnly = false,
  }) async {
    final syncState = ref.read(globalSyncStatusProvider);

    if (syncState.status == SyncStatus.syncing) {
      logInfo('SYNC: Sync already in progress, skipping...');
      return Result.success(null);
    }

    // Skip if last sync was successful and recent (within 1 minute)
    if (!force && syncState.lastSync != null) {
      final timeSinceLastSync = DateTime.now().difference(syncState.lastSync!);
      if (timeSinceLastSync.inMinutes < 1) {
        logInfo(
          'SYNC: Data is fresh (last synced ${timeSinceLastSync.inMinutes}m ago). Skipping...',
        );
        return Result.success(null);
      }
    }

    logInfo(
      'SYNC: Starting restaurant synchronization (metadataOnly: $metadataOnly)...',
    );
    await Future.microtask(() {
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).startSync();
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.05);
      }
    });

    try {
      if (!ref.mounted) return Result.failure(ServerException('Ref unmounted'));
      final db = await ref.read(appDatabaseProvider.future);

      if (clearCache) {
        logInfo('SYNC: Explicitly clearing image cache...');
        try {
          await DefaultCacheManager().emptyCache();
        } catch (e) {
          logWarning('SYNC: Failed to clear image cache: $e');
        }
      }

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.1);
      }

      logInfo('SYNC: Fetching restaurants from Supabase...');
      // Fetch from Supabase - metadata only or deep nesting
      final query = _client
          .from('restaurants')
          .select(
            metadataOnly ? '*' : '*, menu_categories(*, menu_items(*))',
          );
      final response = await query;
      final data = response as List<dynamic>;

      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.3);
      }

      if (data.isEmpty) {
        logWarning('SYNC: No restaurants found in Supabase.');
        if (ref.mounted) {
          ref.read(globalSyncStatusProvider.notifier).completeSync();
        }
        return Result.success(null);
      }

      logInfo('SYNC: Fetched ${data.length} raw restaurant records.');

      if (!ref.mounted) return Result.failure(ServerException('Ref unmounted'));

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

      if (restaurants.isNotEmpty) {
        final first = restaurants.first;
        logInfo(
          'SYNC READY: First Restaurant: ${first.name} | Rating: ${first.rating} | Status: ${first.status.name} | Categories: ${first.categories.length}',
        );
      }

      if (!ref.mounted) return Result.failure(ServerException('Ref unmounted'));

      // ATOMIC SYNC: We use a transaction to clear old data and insert new data
      // This ensures the database is NEVER empty or in a partial state for the user.
      logInfo(
        'SYNC: Starting atomic database sync for ${restaurants.length} restaurants (metadataOnly: $metadataOnly)...',
      );

      // CHUNKED SYNC: Process in smaller chunks with separate transactions
      // to keep memory usage low and prevent long UI blocks.
      const chunkSize = 50;
      final totalChunks = (restaurants.length / chunkSize).ceil();

      for (var i = 0; i < restaurants.length; i += chunkSize) {
        final end = (i + chunkSize < restaurants.length)
            ? i + chunkSize
            : restaurants.length;
        final chunk = restaurants.sublist(i, end);

        await db.transaction(() async {
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

              // Insert Categories only if not metadataOnly
              if (!metadataOnly) {
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
            }
          });
        });

        // Update progress during insertion (from 0.5 to 0.9)
        if (ref.mounted) {
          final currentChunkIdx = i ~/ chunkSize;
          final insertionProgress =
              0.5 + (0.4 * (currentChunkIdx / totalChunks));
          ref
              .read(globalSyncStatusProvider.notifier)
              .updateProgress(insertionProgress);
        }

        // Small Breath
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      // Update sync metadata in a final transaction
      await db.transaction(() async {
        await db
            .into(db.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(
                tableIdentifier: 'restaurants',
                lastSync: DateTime.now(),
              ),
              mode: InsertMode.insertOrReplace,
            );
      });

      logInfo('SYNC: Successfully completed restaurant sync.');

      // Warm up image cache for the newly synced restaurants
      unawaited(_warmupImageCache(restaurants));

      unawaited(
        Future.microtask(() {
          if (ref.mounted) {
            ref.read(globalSyncStatusProvider.notifier).completeSync();
          }
        }),
      );
      return Result.success(null);
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
      return Result.failure(ServerException(e.toString()));
    }
  }

  /// Detailed background sync for menu categories and items.
  Future<Result<void>> syncDetailedHierarchy() async {
    logInfo('SYNC: Starting detailed hierarchy background synchronization...');
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final response = await _client
          .from('restaurants')
          .select('id, menu_categories(*, menu_items(*))');
      final data = response as List<dynamic>;

      logInfo(
        'SYNC: Fetched detailed hierarchy for ${data.length} restaurants.',
      );

      // Heavy JSON parsing in background isolate to avoid blocking UI
      final restaurants = await BackgroundWorker.runHeavyTask(
        _parseRestaurants,
        data,
      );

      logInfo(
        'SYNC: Parsed detailed hierarchy for ${restaurants.length} restaurants.',
      );

      // CHUNKED SYNC: Process in smaller chunks with separate transactions
      // to keep memory usage low and prevent long UI blocks.
      const chunkSize = 20;
      for (var i = 0; i < restaurants.length; i += chunkSize) {
        final end = (i + chunkSize < restaurants.length)
            ? i + chunkSize
            : restaurants.length;
        final chunk = restaurants.sublist(i, end);

        await db.transaction(() async {
          await db.batch((batch) {
            for (final restaurant in chunk) {
              if (restaurant.id == null) continue;

              for (final category in restaurant.categories) {
                if (category.id == null) continue;

                batch.insert(
                  db.cachedMenuCategories,
                  CachedMenuCategoriesCompanion.insert(
                    id: category.id!,
                    restaurantId: restaurant.id!,
                    name: category.name,
                    priority: Value(category.priority),
                  ),
                  mode: InsertMode.insertOrReplace,
                );

                for (final item in category.items) {
                  if (item.id == null) continue;

                  batch.insert(
                    db.cachedMenuItems,
                    CachedMenuItemsCompanion.insert(
                      id: item.id!,
                      categoryId: category.id!,
                      name: item.name,
                      price: item.price,
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
        });

        // Small breather for the event loop and GC
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      logInfo('SYNC: Successfully completed detailed hierarchy sync.');
      return Result.success(null);
    } catch (e, stack) {
      logError('SYNC ERROR: Detailed hierarchy sync failed', e, stack);
      return Result.failure(ServerException(e.toString()));
    }
  }

  /// Fetches orders and their items from Supabase for the current user
  /// and synchronizes them to the local database.
  Future<Result<void>> syncRemoteOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Result.failure(const UnauthorizedException('No user logged in'));
    }

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      if (data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        logInfo(
          'SYNC READY: First Order: ID: ${first['id']} | Status: ${first['status']}',
        );
      }

      await db.transaction(() async {
        await db.batch((batch) {
          for (final orderJson in data) {
            final orderId = orderJson['id'] as String;

            batch.insert(
              db.cachedOrders,
              CachedOrdersCompanion.insert(
                id: orderId,
                restaurantId: orderJson['restaurant_id'] as String,
                status: orderJson['status'] as String,
                paymentStatus:
                    (orderJson['payment_status'] ?? 'pending') as String,
                subtotal: ((orderJson['subtotal'] ?? 0.0) as num).toDouble(),
                deliveryFee: ((orderJson['delivery_fee'] ?? 0.0) as num)
                    .toDouble(),
                taxAmount: ((orderJson['tax_amount'] ?? 0.0) as num).toDouble(),
                discountAmount: ((orderJson['discount_amount'] ?? 0.0) as num)
                    .toDouble(),
                totalAmount: ((orderJson['total_amount'] ?? 0.0) as num)
                    .toDouble(),
                createdAt: DateTime.parse(orderJson['created_at'] as String),
                lastUpdated: Value(DateTime.now()),
              ),
              mode: InsertMode.insertOrReplace,
            );

            final items = orderJson['order_items'] as List?;
            if (items != null) {
              for (final itemJson in items) {
                batch.insert(
                  db.cachedOrderItems,
                  CachedOrderItemsCompanion.insert(
                    id: itemJson['id'] as String,
                    orderId: orderId,
                    menuItemId: Value(itemJson['menu_item_id'] as String?),
                    name: itemJson['name'] as String,
                    quantity: (itemJson['quantity'] ?? 1) as int,
                    unitPrice: ((itemJson['unit_price'] ?? 0.0) as num)
                        .toDouble(),
                    totalPrice: ((itemJson['total_price'] ?? 0.0) as num)
                        .toDouble(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
              }
            }
          }
        });
      });
      logInfo('SYNC: Successfully synchronized ${data.length} orders.');
      return Result.success(null);
    } catch (e) {
      logError('SYNC ERROR: Failed to sync orders from Supabase', e);
      return Result.failure(ServerException(e.toString()));
    }
  }

  /// Fetches the user's cart from Supabase and syncs to local database.
  Future<Result<void>> syncRemoteCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Result.failure(const UnauthorizedException('No user logged in'));
    }

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final response = await _client
          .from('cart_items')
          .select('*')
          .eq('user_id', userId);

      final data = response as List<dynamic>;

      if (data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        logInfo(
          'SYNC READY: First Cart Item: ID: ${first['menu_item_id']} | Name: ${first['name']}',
        );
      }

      await db.transaction(() async {
        await db.batch((batch) {
          for (final item in data) {
            batch.insert(
              db.cachedCartItems,
              CachedCartItemsCompanion.insert(
                menuItemId: item['menu_item_id'] as String,
                restaurantId: Value(item['restaurant_id'] as String?),
                name: item['name'] as String,
                imageUrl: Value(item['image_url'] as String?),
                price: ((item['price_at_purchase'] ?? 0.0) as num).toDouble(),
                quantity: Value((item['quantity'] ?? 1) as int),
                lastUpdated: Value(DateTime.now()),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      logInfo('SYNC: Successfully synchronized ${data.length} cart items.');
      return Result.success(null);
    } catch (e) {
      logError('SYNC ERROR: Failed to sync cart from Supabase', e);
      return Result.failure(ServerException(e.toString()));
    }
  }

  /// Fetches the user's favorites from Supabase and syncs to local database.
  Future<Result<void>> syncRemoteFavourites() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Result.failure(const UnauthorizedException('No user logged in'));
    }

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final response = await _client
          .from('favourites')
          .select('*')
          .eq('user_id', userId);

      final data = response as List<dynamic>;

      if (data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        logInfo(
          'SYNC READY: First Favourite: ID: ${first['item_id']} | Type: ${first['type']}',
        );
      }

      await db.transaction(() async {
        await db.batch((batch) {
          for (final item in data) {
            batch.insert(
              db.cachedFavourites,
              CachedFavouritesCompanion.insert(
                id: item['item_id'] as String,
                type: item['type'] as String,
                addedAt: Value(
                  item['created_at'] != null
                      ? DateTime.parse(item['created_at'] as String)
                      : DateTime.now(),
                ),
                lastUpdated: Value(DateTime.now()),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      logInfo('SYNC: Successfully synchronized ${data.length} favourites.');
      return Result.success(null);
    } catch (e) {
      logError('SYNC ERROR: Failed to sync favourites from Supabase', e);
      return Result.failure(ServerException(e.toString()));
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

    // Trigger UI Overlay for manual sync
    await Future.microtask(() {
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).startSync(isManual: true);
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.1);
      }
    });

    final db = await ref.read(appDatabaseProvider.future);

    try {
      // 1. Export Cart
      final cartRows = await db.select(db.cachedCartItems).get();
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.2);
      }
      for (var i = 0; i < cartRows.length; i++) {
        final row = cartRows[i];
        await pushCartItem({
          'menu_item_id': row.menuItemId,
          'restaurant_id': row.restaurantId,
          'name': row.name,
          'price_at_purchase': row.price,
          'image_url': row.imageUrl,
          'quantity': row.quantity,
        });
        if (ref.mounted) {
          ref
              .read(globalSyncStatusProvider.notifier)
              .updateProgress(0.2 + (0.3 * (i / cartRows.length)));
        }
        await Future<void>.delayed(Duration.zero);
      }

      // 2. Export Favourites
      final favRows = await db.select(db.cachedFavourites).get();
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.5);
      }
      for (var i = 0; i < favRows.length; i++) {
        final row = favRows[i];
        await pushFavourite(row.id, row.type);
        if (ref.mounted) {
          ref
              .read(globalSyncStatusProvider.notifier)
              .updateProgress(0.5 + (0.2 * (i / favRows.length)));
        }
        await Future<void>.delayed(Duration.zero);
      }

      // 3. Export Orders
      final orderRows = await db.select(db.cachedOrders).get();
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).updateProgress(0.7);
      }
      for (var i = 0; i < orderRows.length; i++) {
        final row = orderRows[i];
        final itemRows = await (db.select(
          db.cachedOrderItems,
        )..where((t) => t.orderId.equals(row.id))).get();

        final payload = await compute(_prepareOrderExportPayload, {
          'order': row,
          'items': itemRows,
        });

        await pushOrderToRemote(
          payload['order'] as Map<String, dynamic>,
          payload['items'] as List<Map<String, dynamic>>,
        );
        if (ref.mounted) {
          ref
              .read(globalSyncStatusProvider.notifier)
              .updateProgress(0.7 + (0.3 * (i / orderRows.length)));
        }
        await Future<void>.delayed(Duration.zero);
      }

      logInfo('SYNC COMPLETE: Full export finished successfully.');
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).completeSync();
      }
    } catch (e) {
      logError('SYNC ERROR: Bulk export failed', e);
      if (ref.mounted) {
        ref.read(globalSyncStatusProvider.notifier).failSync(e.toString());
      }
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

  /// Warm up the image cache for the most important UI elements.
  Future<void> _warmupImageCache(List<RestaurantModel> restaurants) async {
    if (restaurants.isEmpty) return;

    logInfo('SYNC: Starting optimized background image pre-caching...');

    final cacheManager = DefaultCacheManager();

    // 1. Group URLs by Priority
    final criticalUrls = <String>{}; // Logos for initial view
    final standardUrls = <String>{}; // Banners for top restaurants

    // Conservative Pre-caching strategy:
    // Only logos for top 20 and banners for top 5. Skip all menu items.
    for (var i = 0; i < restaurants.length; i++) {
      final r = restaurants[i];

      // Logos: Pre-cache top 20 for smooth home screen list scrolling
      if (i < 20 && r.logoUrl != null && r.logoUrl!.isNotEmpty) {
        criticalUrls.add(ImageUtils.getRestaurantThumbnail(r.logoUrl));
      }

      // Banners: Pre-cache only top 5 to save bandwidth and memory
      if (i < 5 && r.bannerUrl != null && r.bannerUrl!.isNotEmpty) {
        standardUrls.add(ImageUtils.getRestaurantBanner(r.bannerUrl));
      }

      // Menu items: Skipping pre-caching entirely to avoid UI thread starvation.
      // These will load on-demand when the user views the restaurant.
    }

    logInfo(
      'SYNC: Found ${criticalUrls.length} critical and ${standardUrls.length} standard images to pre-cache.',
    );

    // 2. Optimized Download Helper with Concurrency Control and Pre-decoding
    Future<void> downloadInBatches(
      Set<String> urls,
      int concurrency, {
      bool precache = false,
    }) async {
      final urlList = urls.toList();
      for (var i = 0; i < urlList.length; i += concurrency) {
        final end = (i + concurrency < urlList.length)
            ? i + concurrency
            : urlList.length;
        final batch = urlList.sublist(i, end);

        // Download batch in parallel
        await Future.wait(
          batch.map(
            (url) async {
              try {
                final file = await cacheManager.downloadFile(url);
                final context = rootNavigatorKey.currentContext;
                if (precache &&
                    ref.mounted &&
                    file != null &&
                    context != null) {
                  // Pre-decode into Flutter's memory cache
                  await precacheImage(
                    CachedNetworkImageProvider(url),
                    context,
                  ).catchError((_) => null);
                }
              } catch (e) {
                // Silently handle download errors for background caching
              }
            },
          ),
        );

        // Increased delay to let the event loop breathe and allow UI interactions
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }

    // 3. Execute with Priority
    // Critical images: Reduced concurrency to prioritize UI responsiveness
    unawaited(
      Future(() async {
        logInfo('SYNC: Pre-caching critical images...');
        await downloadInBatches(criticalUrls, 3, precache: true);
        logInfo('SYNC: Critical images cached. Starting background batch...');
        // Standard images: Lower concurrency to stay "in the background"
        await downloadInBatches(standardUrls, 2);
        logInfo('SYNC: All images pre-cached successfully.');
      }),
    );
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
