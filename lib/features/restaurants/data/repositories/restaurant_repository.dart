import 'package:flutter/foundation.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/models/result.dart';
import 'package:restro_hub/core/utils/app_exception.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_repository.g.dart';

abstract class IRestaurantRepository {
  Future<Result<List<RestaurantModel>>> getRestaurants({
    int limit = 20,
    int offset = 0,
  });
  Stream<List<RestaurantModel>> watchRestaurants();
}

class RestaurantRepositoryImpl implements IRestaurantRepository {
  final Ref _ref;

  RestaurantRepositoryImpl(this._ref);

  @override
  Future<Result<List<RestaurantModel>>> getRestaurants({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await _ref.read(appDatabaseProvider.future);
      final query = db.select(db.cachedRestaurants)
        ..limit(limit, offset: offset);
      final list = await query.get();

      // Offload mapping to background isolate for potential large lists
      final models = await compute(_mapRowsToModels, list);
      return Result.success(models);
    } on Object catch (e) {
      return Result.failure(ServerException(e.toString()));
    }
  }

  @override
  Stream<List<RestaurantModel>> watchRestaurants() {
    return _ref.watch(appDatabaseProvider.future).asStream().asyncExpand(
      (db) {
        return db.select(db.cachedRestaurants).watch().asyncMap((list) {
          return compute(_mapRowsToModels, list);
        });
      },
    );
  }
}

/// Top-level function for background mapping
List<RestaurantModel> _mapRowsToModels(List<CachedRestaurant> rows) {
  return rows.map((row) {
    return RestaurantModel(
      id: row.id,
      ownerId: row.ownerId,
      name: row.name,
      description: row.description ?? '',
      logoUrl: row.logoUrl,
      bannerUrl: row.bannerUrl,
      status: RestaurantStatus.fromString(row.status),
      rating: row.rating,
      priceRange: row.priceRange,
      minOrderAmount: row.minOrderAmount,
      taxPercent: row.taxPercent,
      locationAddress: row.locationAddress,
      latitude: row.latitude,
      longitude: row.longitude,
    );
  }).toList();
}

@riverpod
IRestaurantRepository restaurantRepository(Ref ref) {
  return RestaurantRepositoryImpl(ref);
}
