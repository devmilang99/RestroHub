class CartModel {
  final String? id;
  final String? restaurantId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  CartModel({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.id,
    this.restaurantId,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String?,
      restaurantId: json['restaurant_id'] as String?,
      name: (json['name'] ?? '') as String,
      image: (json['image_url'] ?? '') as String,
      price: ((json['price_at_purchase'] ?? json['price'] ?? 0.0) as num)
          .toDouble(),
      quantity: (json['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'image_url': image,
      'price_at_purchase': price,
      'quantity': quantity,
    };
  }

  CartModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
