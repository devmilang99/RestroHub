import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String name;
  final double rating;
  final String time;
  final String comment;
  final List<String> images;

  const ReviewModel({
    required this.name,
    required this.rating,
    required this.time,
    required this.comment,
    required this.images,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      images: List<String>.from(json['images'] as Iterable? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'time': time,
      'comment': comment,
      'images': images,
    };
  }

  @override
  List<Object?> get props => [name, rating, time, comment, images];
}
