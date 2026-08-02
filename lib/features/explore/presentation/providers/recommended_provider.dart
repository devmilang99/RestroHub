import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommended_provider.g.dart';

@riverpod
Future<List<dynamic>> recommendedItems(Ref ref) async {
  final restaurants = await ref.watch(restaurantsStreamProvider.first);
  final cuisines = await ref.watch(allCuisinesStreamProvider.first);

  final recommendedRestaurants = restaurants
      .where((r) => r.rating > 3.0)
      .toList();

  final recommendedFood = cuisines.where((f) => f.rating > 3.0).toList();

  final combined = [...recommendedRestaurants, ...recommendedFood]..shuffle();

  return combined;
}
