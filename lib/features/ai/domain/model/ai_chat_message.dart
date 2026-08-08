import 'package:equatable/equatable.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:uuid/uuid.dart';

class AiChatMessage extends Equatable {
  final String id;
  final String? text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;
  final List<RestaurantModel> restaurants;
  final List<MenuItemModel> menuItems;

  AiChatMessage({
    required this.isUser,
    this.isError = false,
    String? id,
    this.text,
    DateTime? timestamp,
    this.restaurants = const [],
    this.menuItems = const [],
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [
    id,
    text,
    isUser,
    isError,
    timestamp,
    restaurants,
    menuItems,
  ];

  AiChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isError,
    List<RestaurantModel>? restaurants,
    List<MenuItemModel>? menuItems,
  }) {
    return AiChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isError: isError ?? this.isError,
      timestamp: timestamp,
      restaurants: restaurants ?? this.restaurants,
      menuItems: menuItems ?? this.menuItems,
    );
  }
}
