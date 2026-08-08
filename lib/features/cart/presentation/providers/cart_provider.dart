import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';

import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';

class CartNotifier extends AsyncNotifier<List<CartModel>> {
  @override
  FutureOr<List<CartModel>> build() async {
    // Watch current user to ensure resets on logout
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return [];

    final db = await ref.watch(appDatabaseProvider.future);

    // Watch raw cart items to react to background sync updates
    final items = ref.watch(rawCartItemsStreamProvider).value ?? [];
    return compute(_mapCartRowsToModels, items);
  }

  /// Syncs local cart with Supabase. Call this after login.
  Future<void> syncWithRemote() async {
    final syncManager = ref.read(supabaseSyncManagerProvider.notifier);
    final remoteItems = await syncManager.fetchRemoteCart();

    if (remoteItems.isEmpty) return;

    final db = await ref.read(appDatabaseProvider.future);
    await db.batch((batch) {
      for (final item in remoteItems) {
        batch.insert(
          db.cachedCartItems,
          CachedCartItemsCompanion.insert(
            menuItemId: item['menu_item_id'] as String,
            restaurantId: Value(item['restaurant_id'] as String?),
            name: item['name'] as String,
            price: (item['price_at_purchase'] as num).toDouble(),
            imageUrl: Value(item['image_url'] as String?),
            quantity: Value(item['quantity'] as int),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return compute(_mapCartRowsToModels, items);
    });
  }

  CartModel _mapToModel(CachedCartItem row) {
    return CartModel(
      id: row.menuItemId,
      restaurantId: row.restaurantId,
      name: row.name,
      image: row.imageUrl ?? '',
      price: row.price,
      quantity: row.quantity,
    );
  }

  Future<void> addItem(CartModel item) async {
    final db = await ref.read(appDatabaseProvider.future);
    // Use ID if available, otherwise name. For Supabase data, ID is preferred.
    final id = item.id ?? item.name;

    final existing = await (db.select(
      db.cachedCartItems,
    )..where((t) => t.menuItemId.equals(id))).getSingleOrNull();

    if (existing != null) {
      final newQuantity = existing.quantity + 1;
      await (db.update(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals(id))).write(
        CachedCartItemsCompanion(quantity: Value(newQuantity)),
      );

      // Sync to Supabase
      unawaited(
        ref
            .read(supabaseSyncManagerProvider.notifier)
            .pushCartItem(
              item.copyWith(quantity: newQuantity).toJson(),
            ),
      );
    } else {
      await db
          .into(db.cachedCartItems)
          .insert(
            CachedCartItemsCompanion.insert(
              menuItemId: id,
              restaurantId: Value(item.restaurantId),
              name: item.name,
              price: item.price,
              imageUrl: Value(item.image),
              quantity: Value(item.quantity),
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Sync to Supabase
      unawaited(
        ref
            .read(supabaseSyncManagerProvider.notifier)
            .pushCartItem(
              item.toJson(),
            ),
      );
    }

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return compute(_mapCartRowsToModels, items);
    });
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final db = await ref.read(appDatabaseProvider.future);
    if (quantity <= 0) {
      await (db.delete(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals(id))).go();
      unawaited(
        ref.read(supabaseSyncManagerProvider.notifier).removeCartItem(id),
      );
    } else {
      await (db.update(db.cachedCartItems)
            ..where((t) => t.menuItemId.equals(id)))
          .write(CachedCartItemsCompanion(quantity: Value(quantity)));

      // Get item for sync
      final item = await (db.select(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals(id))).getSingle();
      unawaited(
        ref
            .read(supabaseSyncManagerProvider.notifier)
            .pushCartItem(
              _mapToModel(item).toJson(),
            ),
      );
    }

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return compute(_mapCartRowsToModels, items);
    });
  }

  Future<void> removeItem(String id) async {
    final db = await ref.read(appDatabaseProvider.future);
    await (db.delete(
      db.cachedCartItems,
    )..where((t) => t.menuItemId.equals(id))).go();

    unawaited(
      ref.read(supabaseSyncManagerProvider.notifier).removeCartItem(id),
    );

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return compute(_mapCartRowsToModels, items);
    });
  }

  Future<void> clearCart() async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.delete(db.cachedCartItems).go();
    unawaited(ref.read(supabaseSyncManagerProvider.notifier).clearRemoteCart());
    state = const AsyncValue.data([]);
  }
}

/// Top-level function for background mapping of cart items
List<CartModel> _mapCartRowsToModels(List<CachedCartItem> rows) {
  return rows
      .map(
        (row) => CartModel(
          id: row.menuItemId,
          restaurantId: row.restaurantId,
          name: row.name,
          image: row.imageUrl ?? '',
          price: row.price,
          quantity: row.quantity,
        ),
      )
      .toList();
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartModel>>(() {
  return CartNotifier();
});

/// A stream provider that watches the raw cart items in the local DB.
final rawCartItemsStreamProvider = StreamProvider<List<CachedCartItem>>((
  ref,
) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  yield* db.select(db.cachedCartItems).watch();
});

final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider).value ?? [];
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

final cartTotalAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider).value ?? [];
  return cart.fold<double>(
    0,
    (sum, item) => sum + (item.price * (item.quantity)),
  );
});
