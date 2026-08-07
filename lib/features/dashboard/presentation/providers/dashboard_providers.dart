import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';

final dashboardRecommendedItemsProvider = FutureProvider<List<dynamic>>((
  ref,
) async {
  final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
  final allCuisinesAsync = ref.watch(allCuisinesStreamProvider);

  final restaurants = restaurantsAsync.value ?? [];
  final cuisines = allCuisinesAsync.value ?? [];

  if (restaurants.isEmpty && cuisines.isEmpty) return [];

  final recommendedRestaurants = restaurants
      .where((r) => r.rating >= 4.0)
      .take(5)
      .toList();

  final recommendedFood = cuisines
      .where((f) => f.rating >= 4.5)
      .take(5)
      .toList();

  final combined = [...recommendedRestaurants, ...recommendedFood]
    ..sort((
      a,
      b,
    ) {
      final rA = a is RestaurantModel ? a.rating : (a as MenuItemModel).rating;
      final rB = b is RestaurantModel ? b.rating : (b as MenuItemModel).rating;
      return rB.compareTo(rA);
    });

  return combined;
});

final dashboardPopularRestaurantsProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
      final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
      final restaurants = restaurantsAsync.value ?? [];

      if (restaurants.isEmpty) return [];

      final recommendedRestaurants = restaurants
          .where((r) => r.rating >= 4.0)
          .take(5)
          .toList();

      final allRestaurantsSorted = List<RestaurantModel>.from(restaurants)
        ..sort((a, b) => b.rating.compareTo(a.rating));

      return allRestaurantsSorted
          .where((r) => !recommendedRestaurants.any((rec) => rec.id == r.id))
          .take(5)
          .toList();
    });

final dashboardBestPickFoodProvider = FutureProvider<List<MenuItemModel>>((
  ref,
) async {
  final allCuisinesAsync = ref.watch(allCuisinesStreamProvider);
  final allCuisines = allCuisinesAsync.value ?? [];
  return allCuisines.take(5).toList();
});
