import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:restro_hub/core/utils/logger.dart';

part 'app_database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    return (json.decode(fromDb) as List).map((e) => e.toString()).toList();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class CachedRestaurants extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get bannerUrl => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('closed'))();
  RealColumn get rating => real().withDefault(const Constant(0))();
  TextColumn get priceRange => text().withDefault(const Constant(r'$$'))();
  RealColumn get minOrderAmount => real().withDefault(const Constant(0))();
  RealColumn get taxPercent => real().withDefault(const Constant(0))();
  TextColumn get locationAddress => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedMenuCategories extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId =>
      text().references(CachedRestaurants, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get priority => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedMenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(
    CachedMenuCategories,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  IntColumn get calories => integer().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get dietaryFlags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedUserAddresses extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withDefault(const Constant('Home'))();
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get city => text()();
  TextColumn get state => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedOrders extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get status => text()();
  TextColumn get paymentStatus => text()();
  RealColumn get subtotal => real()();
  RealColumn get deliveryFee => real()();
  RealColumn get taxAmount => real()();
  RealColumn get discountAmount => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get progress => real().withDefault(const Constant(0))();
  DateTimeColumn get phaseStartTime => dateTime().nullable()();
  DateTimeColumn get targetConfirmationTime => dateTime().nullable()();
  IntColumn get remainingPendingSeconds => integer().nullable()();
  BoolColumn get isPendingPaused =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(
    CachedOrders,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get menuItemId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedFavourites extends Table {
  TextColumn get id => text()(); // Either restaurantId or menuItemId
  TextColumn get type => text()(); // 'restaurant' or 'menu_item'
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedCartItems extends Table {
  TextColumn get menuItemId => text()();
  TextColumn get restaurantId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get price => real()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {menuItemId};
}

class SyncMetadata extends Table {
  TextColumn get tableIdentifier => text()();
  DateTimeColumn get lastSync => dateTime()();

  @override
  Set<Column> get primaryKey => {tableIdentifier};
}

@DriftDatabase(
  tables: [
    CachedRestaurants,
    CachedMenuCategories,
    CachedMenuItems,
    CachedUserAddresses,
    CachedOrders,
    CachedOrderItems,
    CachedFavourites,
    CachedCartItems,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      logInfo('Database onCreate: Creating all tables.');
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {},
  );

  /// Clears all user-related temporary data from the database.
  Future<void> clearAllUserData() async {
    await transaction(() async {
      await delete(cachedCartItems).go();
      await delete(cachedFavourites).go();
      await delete(cachedOrders).go();
      await delete(cachedOrderItems).go();
      await delete(cachedUserAddresses).go();
      await delete(syncMetadata).go();
      // Optionally clear cached restaurants if you want a full reset
      // await delete(cachedRestaurants).go();
    });
  }

  /// Clears restaurant and menu data to prepare for a fresh sync.
  Future<void> clearRestaurantData() async {
    await transaction(() async {
      // Deleting restaurants will cascade to categories and items due to foreign keys
      await delete(cachedRestaurants).go();
      await delete(syncMetadata).go();
    });
  }

  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'restro_hub_v2.sqlite'));

      return NativeDatabase.createInBackground(
        file,
        logStatements: false,
        setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        },
      );
    });
  }
}
