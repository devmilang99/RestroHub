import 'package:equatable/equatable.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';

sealed class FavouriteItem extends Equatable {
  const FavouriteItem();

  String get id;
  String get name;
  String get description;
  String? get imageUrl;
}

class RestaurantFavourite extends FavouriteItem {
  final RestaurantModel restaurant;
  const RestaurantFavourite(this.restaurant);

  @override
  String get id => restaurant.id ?? '';
  @override
  String get name => restaurant.name;
  @override
  String get description => restaurant.description;
  @override
  String? get imageUrl => restaurant.logoUrl;

  @override
  List<Object?> get props => [restaurant];
}

class MenuItemFavourite extends FavouriteItem {
  final MenuItemModel menuItem;
  const MenuItemFavourite(this.menuItem);

  @override
  String get id => menuItem.id ?? '';
  @override
  String get name => menuItem.name;
  @override
  String get description => menuItem.description;
  @override
  String? get imageUrl => menuItem.imageUrl;

  @override
  List<Object?> get props => [menuItem];
}
