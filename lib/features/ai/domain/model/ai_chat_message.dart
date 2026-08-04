import 'package:equatable/equatable.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:uuid/uuid.dart';

class AiChatMessage extends Equatable {
  final String id;
  final String? text;
  final bool isUser;
  final DateTime timestamp;
  final List<RestaurantModel> restaurants;

  AiChatMessage({
    required this.isUser,
    String? id,
    this.text,
    DateTime? timestamp,
    this.restaurants = const [],
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [id, text, isUser, timestamp, restaurants];

  AiChatMessage copyWith({
    String? text,
    bool? isUser,
    List<RestaurantModel>? restaurants,
  }) {
    return AiChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp,
      restaurants: restaurants ?? this.restaurants,
    );
  }
}
