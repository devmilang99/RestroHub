import 'package:equatable/equatable.dart';
import 'package:restro_hub/features/cuisines/data/models/cuisine_model.dart';

/// Restaurant Model representing a dining establishment.
class RestaurantModel extends Equatable {
  final String name;
  final String image;
  final String rating;
  final String description;
  final String location;
  final String deliveryTime;
  final String priceRange;
  final List<CuisineModel> menu;

  const RestaurantModel({
    required this.name,
    required this.image,
    required this.rating,
    required this.description,
    required this.location,
    required this.deliveryTime,
    required this.priceRange,
    required this.menu,
  });

  @override
  List<Object?> get props => [
    name,
    image,
    rating,
    description,
    location,
    deliveryTime,
    priceRange,
    menu,
  ];
}
