import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';

class CartNotifier extends AsyncNotifier<List<CartModel>> {
  @override
  FutureOr<List<CartModel>> build() async {
    final db = await ref.watch(appDatabaseProvider.future);
    final items = await db.select(db.cachedCartItems).get();
    return items.map(_mapToModel).toList();
  }

  CartModel _mapToModel(CachedCartItem row) {
    return CartModel(
      id: row.menuItemId,
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
      await (db.update(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals(id))).write(
        CachedCartItemsCompanion(quantity: Value(existing.quantity + 1)),
      );
    } else {
      await db
          .into(db.cachedCartItems)
          .insert(
            CachedCartItemsCompanion.insert(
              menuItemId: id,
              name: item.name,
              price: item.price,
              imageUrl: Value(item.image),
              quantity: Value(item.quantity),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return items.map(_mapToModel).toList();
    });
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final db = await ref.read(appDatabaseProvider.future);
    if (quantity <= 0) {
      await (db.delete(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals(id))).go();
    } else {
      await (db.update(db.cachedCartItems)
            ..where((t) => t.menuItemId.equals(id)))
          .write(CachedCartItemsCompanion(quantity: Value(quantity)));
    }

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return items.map(_mapToModel).toList();
    });
  }

  Future<void> removeItem(String id) async {
    final db = await ref.read(appDatabaseProvider.future);
    await (db.delete(
      db.cachedCartItems,
    )..where((t) => t.menuItemId.equals(id))).go();

    state = await AsyncValue.guard(() async {
      final items = await db.select(db.cachedCartItems).get();
      return items.map(_mapToModel).toList();
    });
  }

  Future<void> clearCart() async {
    final db = await ref.read(appDatabaseProvider.future);
    await db.delete(db.cachedCartItems).go();
    state = const AsyncValue.data([]);
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartModel>>(() {
  return CartNotifier();
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
