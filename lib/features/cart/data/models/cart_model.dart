class CartModel {
  final String name;
  final String image;
  final double price;
  final int quantity;

  CartModel({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  CartModel copyWith({
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartModel(
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
