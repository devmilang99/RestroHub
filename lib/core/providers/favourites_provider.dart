import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/models/cuisines_item.dart';

class FavouritesNotiifier extends Notifier<List<CuisinesItem>> {
  @override
  List<CuisinesItem> build() {
    return [];
  }

  void addToFavourites(CuisinesItem item) {
    state = [...state, item];
  }

  void removeFromFavourites(CuisinesItem item) {
    state = state.where((element) => element != item).toList();
  }

  List<CuisinesItem> listFromFavourites() {
    return state;
  }
}

final favouritesProvider =
    NotifierProvider<FavouritesNotiifier, List<CuisinesItem>>(() {
      return FavouritesNotiifier();
    });
