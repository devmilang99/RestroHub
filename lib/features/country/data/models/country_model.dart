import 'package:equatable/equatable.dart';

/// Country Model representing a geographic location for cuisines.
/// Renamed from Country to CountryModel for consistency.
class CountryModel extends Equatable {
  final String name;
  final String flag;
  final String image;
  final String historicalImage;

  const CountryModel({
    required this.name,
    required this.flag,
    required this.image,
    required this.historicalImage,
  });

  @override
  List<Object?> get props => [name, flag, image, historicalImage];
}
