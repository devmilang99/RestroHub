import 'package:equatable/equatable.dart';

class CuisinesItem extends Equatable {
  final String name;
  final String image;
  final String rating;
  final String offerPercent;
  final String description;
  final List<String> ingredients;
  final List<String> comments;
  final double price;
  final String location;
  final String country;

  const CuisinesItem({
    required this.name,
    required this.image,
    required this.rating,
    required this.offerPercent,
    this.price = 500.0,
    this.location = "Narayan Chowk",
    this.description = "A delicious dish prepared with the finest ingredients.",
    this.ingredients = const ["Rice", "Spices", "Oils", "Vegetables"],
    this.comments = const [
      "Amazing food!",
      "Best I've ever had!",
      "Highly recommend.",
    ],
    this.country = "Nepal",
  });

  @override
  List<Object?> get props => [
    name,
    image,
    rating,
    offerPercent,
    description,
    ingredients,
    comments,
    price,
    location,
    country,
  ];
}
