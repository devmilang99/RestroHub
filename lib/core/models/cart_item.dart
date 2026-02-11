class CartItem {
  final String name;
  final String image;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
