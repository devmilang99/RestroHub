import 'package:equatable/equatable.dart';
import 'package:restro_hub/features/ai/domain/model/ai_chat_message.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';

class AiSearchState extends Equatable {
  final List<AiChatMessage> messages;
  final bool isProcessing;
  final String? error;
  final List<RestaurantModel> restaurants;
  final List<MenuItemModel> menuItems;
  final List<String> history;
  final int searchCount;
  final int errorCount;

  const AiSearchState({
    this.messages = const [],
    this.isProcessing = false,
    this.error,
    this.restaurants = const [],
    this.menuItems = const [],
    this.history = const [],
    this.searchCount = 0,
    this.errorCount = 0,
  });

  AiSearchState copyWith({
    List<AiChatMessage>? messages,
    bool? isProcessing,
    String? error,
    List<RestaurantModel>? restaurants,
    List<MenuItemModel>? menuItems,
    List<String>? history,
    int? searchCount,
    int? errorCount,
  }) {
    return AiSearchState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      restaurants: restaurants ?? this.restaurants,
      menuItems: menuItems ?? this.menuItems,
      history: history ?? this.history,
      searchCount: searchCount ?? this.searchCount,
      errorCount: errorCount ?? this.errorCount,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isProcessing,
    error,
    restaurants,
    menuItems,
    history,
    searchCount,
    errorCount,
  ];
}
