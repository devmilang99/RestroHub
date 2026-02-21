import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/cuisines/data/models/cuisine_model.dart';

class FavouritesNotifier extends Notifier<List<CuisineModel>> {
  @override
  List<CuisineModel> build() {
    return [];
  }

  void toggleFavourite(CuisineModel item) {
    if (isFavourite(item)) {
      removeFromFavourites(item);
    } else {
      addToFavourites(item);
    }
  }

  bool isFavourite(CuisineModel item) {
    return state.any((element) => element.name == item.name);
  }

  void addToFavourites(CuisineModel item) {
    if (!isFavourite(item)) {
      state = [...state, item];
    }
  }

  void removeFromFavourites(CuisineModel item) {
    state = state.where((element) => element.name != item.name).toList();
  }
}

final favouritesProvider =
    NotifierProvider<FavouritesNotifier, List<CuisineModel>>(() {
      return FavouritesNotifier();
    });
