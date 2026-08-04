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
  final List<DateTime> searchTimestamps;
  final int errorCount;

  const AiSearchState({
    this.messages = const [],
    this.isProcessing = false,
    this.error,
    this.restaurants = const [],
    this.menuItems = const [],
    this.history = const [],
    this.searchTimestamps = const [],
    this.errorCount = 0,
  });

  int get searchCount {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    return searchTimestamps.where((t) => t.isAfter(oneHourAgo)).length;
  }

  AiSearchState copyWith({
    List<AiChatMessage>? messages,
    bool? isProcessing,
    String? error,
    List<RestaurantModel>? restaurants,
    List<MenuItemModel>? menuItems,
    List<String>? history,
    List<DateTime>? searchTimestamps,
    int? errorCount,
  }) {
    return AiSearchState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      restaurants: restaurants ?? this.restaurants,
      menuItems: menuItems ?? this.menuItems,
      history: history ?? this.history,
      searchTimestamps: searchTimestamps ?? this.searchTimestamps,
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
    searchTimestamps,
    errorCount,
  ];
}
