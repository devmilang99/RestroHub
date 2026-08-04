import 'dart:math';

import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommended_provider.g.dart';

@riverpod
Future<List<dynamic>> recommendedItems(Ref ref) async {
  final restaurants = await ref.watch(restaurantsStreamProvider.future);
  final cuisines = await ref.watch(allCuisinesStreamProvider.future);

  final recommendedRestaurants = restaurants
      .where((r) => r.rating >= 4.0)
      .toList();

  final recommendedFood = cuisines.where((f) => f.rating >= 4.0).toList();

  final combined = [...recommendedRestaurants, ...recommendedFood];

  // Randomize order so restaurants and food items are interleaved
  // when showing the full "See all" recommended list.
  combined.shuffle(Random());

  return combined;
}
