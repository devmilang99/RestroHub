import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String name;
  final String flag;
  final String image;
  final String historicalImage;

  const Country({
    required this.name,
    required this.flag,
    required this.image,
    required this.historicalImage,
  });

  @override
  List<Object?> get props => [name, flag, image, historicalImage];
}
