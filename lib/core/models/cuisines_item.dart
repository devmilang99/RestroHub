import 'package:equatable/equatable.dart';

class CuisinesItem extends Equatable {
  final String name;
  final String image;
  final String rating;
  final String offerPercent;

  const CuisinesItem({
    required this.name,
    required this.image,
    required this.rating,
    required this.offerPercent,
  });

  @override
  List<Object?> get props => [name, image, rating, offerPercent];
}