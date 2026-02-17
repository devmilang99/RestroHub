import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/models/cuisines_item.dart';

class FavouritesNotifier extends Notifier<List<CuisinesItem>> {
  @override
  List<CuisinesItem> build() {
    return [];
  }

  void toggleFavourite(CuisinesItem item) {
    if (isFavourite(item)) {
      removeFromFavourites(item);
    } else {
      addToFavourites(item);
    }
  }

  bool isFavourite(CuisinesItem item) {
    return state.any((element) => element.name == item.name);
  }

  void addToFavourites(CuisinesItem item) {
    if (!isFavourite(item)) {
      state = [...state, item];
    }
  }

  void removeFromFavourites(CuisinesItem item) {
    state = state.where((element) => element.name != item.name).toList();
  }
}

final favouritesProvider =
    NotifierProvider<FavouritesNotifier, List<CuisinesItem>>(() {
      return FavouritesNotifier();
    });
