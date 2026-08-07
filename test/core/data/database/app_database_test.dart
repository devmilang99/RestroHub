import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restro_hub/core/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('CachedRestaurants', () {
    test('should insert and retrieve a restaurant', () async {
      final restaurant = CachedRestaurantsCompanion.insert(
        id: 'res_1',
        name: 'Test Restaurant',
        status: const Value('open'),
        rating: const Value(4.5),
        minOrderAmount: const Value(15.0),
        taxPercent: const Value(13.0),
      );

      await db.into(db.cachedRestaurants).insert(restaurant);

      final result = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.equals('res_1'))).getSingle();

      expect(result.id, 'res_1');
      expect(result.name, 'Test Restaurant');
      expect(result.status, 'open');
      expect(result.rating, 4.5);
      expect(result.minOrderAmount, 15.0);
      expect(result.taxPercent, 13.0);
    });

    test('should update a restaurant', () async {
      await db
          .into(db.cachedRestaurants)
          .insert(
            CachedRestaurantsCompanion.insert(
              id: 'res_1',
              name: 'Old Name',
            ),
          );

      await (db.update(db.cachedRestaurants)
            ..where((t) => t.id.equals('res_1')))
          .write(const CachedRestaurantsCompanion(name: Value('New Name')));

      final result = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.equals('res_1'))).getSingle();
      expect(result.name, 'New Name');
    });
  });

  group('Menu Hierarchy and Cascade Delete', () {
    test(
      'should delete categories and items when restaurant is deleted',
      () async {
        // 1. Insert Restaurant
        await db
            .into(db.cachedRestaurants)
            .insert(
              CachedRestaurantsCompanion.insert(
                id: 'res_1',
                name: 'Restaurant 1',
              ),
            );

        // 2. Insert Category
        await db
            .into(db.cachedMenuCategories)
            .insert(
              CachedMenuCategoriesCompanion.insert(
                id: 'cat_1',
                restaurantId: 'res_1',
                name: 'Category 1',
              ),
            );

        // 3. Insert Menu Item
        await db
            .into(db.cachedMenuItems)
            .insert(
              CachedMenuItemsCompanion.insert(
                id: 'item_1',
                categoryId: 'cat_1',
                name: 'Item 1',
                price: 10.0,
              ),
            );

        // Verify insertion
        final itemsBefore = await db.select(db.cachedMenuItems).get();
        expect(itemsBefore.length, 1);

        // 4. Delete Restaurant
        await (db.delete(
          db.cachedRestaurants,
        )..where((t) => t.id.equals('res_1'))).go();

        // Verify cascade delete
        final categoriesAfter = await db.select(db.cachedMenuCategories).get();
        final itemsAfter = await db.select(db.cachedMenuItems).get();

        expect(categoriesAfter, isEmpty);
        expect(itemsAfter, isEmpty);
      },
    );
  });

  group('CachedCartItems', () {
    test('should manage cart items', () async {
      // Insert
      await db
          .into(db.cachedCartItems)
          .insert(
            CachedCartItemsCompanion.insert(
              menuItemId: 'item_1',
              name: 'Burger',
              price: 9.99,
              quantity: const Value(1),
              restaurantId: const Value('res_1'),
            ),
          );

      var cart = await db.select(db.cachedCartItems).get();
      expect(cart.length, 1);
      expect(cart.first.quantity, 1);
      expect(cart.first.restaurantId, 'res_1');

      // Update quantity
      await (db.update(db.cachedCartItems)
            ..where((t) => t.menuItemId.equals('item_1')))
          .write(const CachedCartItemsCompanion(quantity: Value(2)));

      cart = await db.select(db.cachedCartItems).get();
      expect(cart.first.quantity, 2);

      // Delete
      await (db.delete(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals('item_1'))).go();
      cart = await db.select(db.cachedCartItems).get();
      expect(cart, isEmpty);
    });
  });

  group('CachedFavourites', () {
    test('should add and remove favourites', () async {
      await db
          .into(db.cachedFavourites)
          .insert(
            CachedFavouritesCompanion.insert(
              id: 'res_1',
              type: 'restaurant',
            ),
          );

      final favourites = await db.select(db.cachedFavourites).get();
      expect(favourites.length, 1);
      expect(favourites.first.id, 'res_1');

      await (db.delete(
        db.cachedFavourites,
      )..where((t) => t.id.equals('res_1'))).go();
      expect(await db.select(db.cachedFavourites).get(), isEmpty);
    });
  });

  group('CachedUserAddresses', () {
    test('should insert and retrieve addresses', () async {
      await db
          .into(db.cachedUserAddresses)
          .insert(
            CachedUserAddressesCompanion.insert(
              id: 'addr_1',
              label: const Value('Work'),
              addressLine1: '123 Tech Park',
              city: 'Kathmandu',
              isDefault: const Value(true),
            ),
          );

      final result = await (db.select(
        db.cachedUserAddresses,
      )..where((t) => t.id.equals('addr_1'))).getSingle();

      expect(result.label, 'Work');
      expect(result.addressLine1, '123 Tech Park');
      expect(result.isDefault, isTrue);
    });
  });

  group('TypeConverters', () {
    test('StringListConverter should handle dietary flags', () async {
      final flags = ['Vegan', 'Gluten-Free'];

      // Satisfy foreign keys first
      await db
          .into(db.cachedRestaurants)
          .insert(
            CachedRestaurantsCompanion.insert(id: 'dummy_res', name: 'Dummy'),
          );
      await db
          .into(db.cachedMenuCategories)
          .insert(
            CachedMenuCategoriesCompanion.insert(
              id: 'dummy_cat',
              restaurantId: 'dummy_res',
              name: 'Veg',
            ),
          );

      await db
          .into(db.cachedMenuItems)
          .insert(
            CachedMenuItemsCompanion.insert(
              id: 'item_1',
              categoryId: 'dummy_cat',
              name: 'Salad',
              price: 12.0,
              dietaryFlags: Value(flags),
            ),
          );

      final item = await (db.select(
        db.cachedMenuItems,
      )..where((t) => t.id.equals('item_1'))).getSingle();
      expect(item.dietaryFlags, flags);
    });
  });

  group('Orders and Order Items', () {
    test('should insert order and items and verify retrieval', () async {
      final now = DateTime.now();
      await db
          .into(db.cachedOrders)
          .insert(
            CachedOrdersCompanion.insert(
              id: 'order_1',
              restaurantId: 'res_1',
              status: 'pending',
              paymentStatus: 'paid',
              subtotal: 100.0,
              deliveryFee: 10.0,
              taxAmount: 5.0,
              discountAmount: 0.0,
              totalAmount: 115.0,
              createdAt: now,
            ),
          );

      await db
          .into(db.cachedOrderItems)
          .insert(
            CachedOrderItemsCompanion.insert(
              id: 'oi_1',
              orderId: 'order_1',
              name: 'Pizza',
              quantity: 2,
              unitPrice: 50.0,
              totalPrice: 100.0,
            ),
          );

      final order = await (db.select(
        db.cachedOrders,
      )..where((t) => t.id.equals('order_1'))).getSingle();
      final items = await (db.select(
        db.cachedOrderItems,
      )..where((t) => t.orderId.equals('order_1'))).get();

      expect(order.id, 'order_1');
      expect(order.totalAmount, 115.0);
      expect(items.length, 1);
      expect(items.first.name, 'Pizza');
      expect(items.first.quantity, 2);
    });
  });

  group('Logout (clearAllUserData)', () {
    test(
      'should clear all sensitive user data but preserve restaurants',
      () async {
        // 1. Populate tables
        await db
            .into(db.cachedRestaurants)
            .insert(
              CachedRestaurantsCompanion.insert(
                id: 'res_1',
                name: 'Restaurant',
              ),
            );
        await db
            .into(db.cachedCartItems)
            .insert(
              CachedCartItemsCompanion.insert(
                menuItemId: 'item_1',
                name: 'Item',
                price: 10.0,
              ),
            );
        await db
            .into(db.cachedFavourites)
            .insert(
              CachedFavouritesCompanion.insert(id: 'fav_1', type: 'restaurant'),
            );
        await db
            .into(db.cachedOrders)
            .insert(
              CachedOrdersCompanion.insert(
                id: 'order_1',
                restaurantId: 'res_1',
                status: 'done',
                paymentStatus: 'paid',
                subtotal: 10,
                deliveryFee: 0,
                taxAmount: 0,
                discountAmount: 0,
                totalAmount: 10,
                createdAt: DateTime.now(),
              ),
            );
        await db
            .into(db.cachedUserAddresses)
            .insert(
              CachedUserAddressesCompanion.insert(
                id: 'addr_1',
                addressLine1: 'Line 1',
                city: 'City',
              ),
            );
        await db
            .into(db.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(
                tableIdentifier: 'table',
                lastSync: DateTime.now(),
              ),
            );

        // 2. Verify data exists
        expect((await db.select(db.cachedCartItems).get()).length, 1);
        expect((await db.select(db.cachedFavourites).get()).length, 1);
        expect((await db.select(db.cachedOrders).get()).length, 1);
        expect((await db.select(db.cachedUserAddresses).get()).length, 1);
        expect((await db.select(db.syncMetadata).get()).length, 1);
        expect((await db.select(db.cachedRestaurants).get()).length, 1);

        // 3. Perform logout (clear user data)
        await db.clearAllUserData();

        // 4. Verify user data is gone
        expect(await db.select(db.cachedCartItems).get(), isEmpty);
        expect(await db.select(db.cachedFavourites).get(), isEmpty);
        expect(await db.select(db.cachedOrders).get(), isEmpty);
        expect(await db.select(db.cachedUserAddresses).get(), isEmpty);
        expect(await db.select(db.syncMetadata).get(), isEmpty);

        // 5. Verify restaurants are still there (cached public data)
        expect((await db.select(db.cachedRestaurants).get()).length, 1);
      },
    );
  });

  group('Sync Maintenance (clearRestaurantData)', () {
    test('should clear restaurants and sync metadata', () async {
      await db
          .into(db.cachedRestaurants)
          .insert(
            CachedRestaurantsCompanion.insert(id: 'res_1', name: 'Res 1'),
          );
      await db
          .into(db.syncMetadata)
          .insert(
            SyncMetadataCompanion.insert(
              tableIdentifier: 'res',
              lastSync: DateTime.now(),
            ),
          );

      expect((await db.select(db.cachedRestaurants).get()).length, 1);
      expect((await db.select(db.syncMetadata).get()).length, 1);

      await db.clearRestaurantData();

      expect(await db.select(db.cachedRestaurants).get(), isEmpty);
      expect(await db.select(db.syncMetadata).get(), isEmpty);
    });
  });

  group('SyncMetadata', () {
    test('should insert or replace sync metadata', () async {
      final now = DateTime.now();
      await db
          .into(db.syncMetadata)
          .insert(
            SyncMetadataCompanion.insert(
              tableIdentifier: 'restaurants',
              lastSync: now,
            ),
            mode: InsertMode.insertOrReplace,
          );

      var result = await (db.select(
        db.syncMetadata,
      )..where((t) => t.tableIdentifier.equals('restaurants'))).getSingle();
      // Drift might truncate milliseconds depending on the executor, so we compare seconds
      expect(
        result.lastSync.millisecondsSinceEpoch ~/ 1000,
        now.millisecondsSinceEpoch ~/ 1000,
      );

      final later = now.add(const Duration(minutes: 5));
      await db
          .into(db.syncMetadata)
          .insert(
            SyncMetadataCompanion.insert(
              tableIdentifier: 'restaurants',
              lastSync: later,
            ),
            mode: InsertMode.insertOrReplace,
          );

      result = await (db.select(
        db.syncMetadata,
      )..where((t) => t.tableIdentifier.equals('restaurants'))).getSingle();
      expect(
        result.lastSync.millisecondsSinceEpoch ~/ 1000,
        later.millisecondsSinceEpoch ~/ 1000,
      );
    });
  });

  group('Batch Operations', () {
    test('should perform batch insertion', () async {
      await db.batch((batch) {
        batch.insertAll(db.cachedRestaurants, [
          CachedRestaurantsCompanion.insert(id: '1', name: 'R1'),
          CachedRestaurantsCompanion.insert(id: '2', name: 'R2'),
          CachedRestaurantsCompanion.insert(id: '3', name: 'R3'),
        ]);
      });

      final restaurants = await db.select(db.cachedRestaurants).get();
      expect(restaurants.length, 3);
    });
  });

  group('Reactive Streams (Watchers)', () {
    test('watch() should emit new data when table changes', () async {
      final stream = db.select(db.cachedCartItems).watch();

      final expectation = expectLater(
        stream,
        emitsInOrder([
          isEmpty, // 1. Initial state (empty)
          hasLength(1), // 2. After insert
          isEmpty, // 3. After delete
        ]),
      );

      // Give a tiny delay to ensure the stream listener is fully set up
      await Future.delayed(Duration.zero);

      await db
          .into(db.cachedCartItems)
          .insert(
            CachedCartItemsCompanion.insert(
              menuItemId: '1',
              name: 'Item 1',
              price: 10,
            ),
          );

      await (db.delete(
        db.cachedCartItems,
      )..where((t) => t.menuItemId.equals('1'))).go();

      await expectation;
    });
  });

  group('Transactions and Rollbacks', () {
    test('transaction should rollback on error', () async {
      try {
        await db.transaction(() async {
          // 1. Valid insert
          await db
              .into(db.cachedRestaurants)
              .insert(
                CachedRestaurantsCompanion.insert(
                  id: 'tx_res',
                  name: 'Valid Res',
                ),
              );

          // 2. Trigger error (Invalid FK because restaurantId 'NON_EXISTENT' doesn't exist)
          await db
              .into(db.cachedMenuCategories)
              .insert(
                CachedMenuCategoriesCompanion.insert(
                  id: 'cat_1',
                  restaurantId: 'NON_EXISTENT',
                  name: 'Error Cat',
                ),
              );
        });
      } catch (_) {
        // Expected error from FK constraint
      }

      // Verify that 'tx_res' was NOT saved because the transaction failed and rolled back
      final results = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.equals('tx_res'))).get();
      expect(results, isEmpty);
    });
  });

  group('Column Defaults', () {
    test('should apply default values for status and rating', () async {
      await db
          .into(db.cachedRestaurants)
          .insert(
            CachedRestaurantsCompanion.insert(id: 'def_1', name: 'Default Res'),
          );

      final res = await (db.select(
        db.cachedRestaurants,
      )..where((t) => t.id.equals('def_1'))).getSingle();

      expect(res.status, 'closed'); // Default value from table definition
      expect(res.rating, 0.0); // Default value from table definition
    });
  });
}
