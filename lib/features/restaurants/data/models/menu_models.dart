import 'package:equatable/equatable.dart';

/// Categories like 'Appetizers', 'Main Course', etc.
class MenuCategoryModel extends Equatable {
  final String? id;
  final String restaurantId;
  final String name;
  final int priority;
  final List<MenuItemModel> items;

  const MenuCategoryModel({
    required this.restaurantId,
    required this.name,
    this.id,
    this.priority = 0,
    this.items = const [],
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id']?.toString(),
      restaurantId:
          (json['restaurant_id'] ?? json['restaurantId'])?.toString() ?? '',
      name: (json['name'] ?? '') as String,
      priority: (json['priority'] ?? 0) as int,
      items: json['menu_items'] != null
          ? (json['menu_items'] as List)
                .map((i) => MenuItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'priority': priority,
    };
  }

  @override
  List<Object?> get props => [id, restaurantId, name, priority, items];
}

/// Individual food items.
class MenuItemModel extends Equatable {
  final String? id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? calories;
  final List<String> dietaryFlags;

  const MenuItemModel({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.id,
    this.imageUrl,
    this.isAvailable = true,
    this.calories,
    this.dietaryFlags = const [],
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id']?.toString(),
      categoryId: (json['category_id'] ?? json['categoryId'])?.toString() ?? '',
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: ((json['price'] ?? 0.0) as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: (json['is_available'] ?? true) as bool,
      calories: json['calories'] as int?,
      dietaryFlags: List<String>.from(json['dietary_flags'] as Iterable? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'calories': calories,
      'dietary_flags': dietaryFlags,
    };
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    description,
    price,
    imageUrl,
    isAvailable,
    calories,
    dietaryFlags,
  ];
}

/// Customizations like 'Extra Cheese', 'Spice Level'.
class MenuItemOptionModel extends Equatable {
  final String? id;
  final String menuItemId;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<MenuItemOptionValueModel> values;

  const MenuItemOptionModel({
    required this.menuItemId,
    required this.name,
    this.id,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection = 1,
    this.values = const [],
  });

  factory MenuItemOptionModel.fromJson(Map<String, dynamic> json) {
    return MenuItemOptionModel(
      id: json['id'] as String?,
      menuItemId: json['menu_item_id'] as String,
      name: (json['name'] ?? '') as String,
      isRequired: (json['is_required'] ?? false) as bool,
      minSelection: (json['min_selection'] ?? 0) as int,
      maxSelection: (json['max_selection'] ?? 1) as int,
      values: json['menu_item_option_values'] != null
          ? (json['menu_item_option_values'] as List)
                .map(
                  (i) => MenuItemOptionValueModel.fromJson(
                    i as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    menuItemId,
    name,
    isRequired,
    minSelection,
    maxSelection,
    values,
  ];
}

class MenuItemOptionValueModel extends Equatable {
  final String? id;
  final String optionId;
  final String name;
  final double priceAdjustment;
  final bool isAvailable;

  const MenuItemOptionValueModel({
    required this.optionId,
    required this.name,
    this.id,
    this.priceAdjustment = 0.0,
    this.isAvailable = true,
  });

  factory MenuItemOptionValueModel.fromJson(Map<String, dynamic> json) {
    return MenuItemOptionValueModel(
      id: json['id'] as String?,
      optionId: json['option_id'] as String,
      name: (json['name'] ?? '') as String,
      priceAdjustment: ((json['price_adjustment'] ?? 0.0) as num).toDouble(),
      isAvailable: (json['is_available'] ?? true) as bool,
    );
  }

  @override
  List<Object?> get props => [id, optionId, name, priceAdjustment, isAvailable];
}
