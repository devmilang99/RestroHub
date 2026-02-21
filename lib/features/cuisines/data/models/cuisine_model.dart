/// Cuisine Model representing a food item.
/// Renamed from CuisinesItem to follow clean naming conventions.
class CuisineModel {
  final String name;
  final String description;
  final String image;
  final String rating;
  final double price;
  final String offerPercent;
  final String location;
  final String? country;
  final List<String> ingredients;
  final List<String> comments;

  CuisineModel({
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.price,
    this.offerPercent = "0%",
    required this.location,
    this.country,
    this.ingredients = const [],
    this.comments = const [],
  });
}
