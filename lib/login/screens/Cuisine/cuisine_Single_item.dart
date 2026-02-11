import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/models/cart_item.dart';
import 'package:restro_hub/core/providers/cart_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class CuisineSingleItem extends StatefulWidget {
  const CuisineSingleItem({super.key, required this.id});

  final String id;

  @override
  State<CuisineSingleItem> createState() => _CuisineSingleItemState();
}

class _CuisineSingleItemState extends State<CuisineSingleItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.id,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: singleItem.length,
                itemBuilder: (context, index) {
                  final item = singleItem[index];
                  return SingleItemCard(
                    specificItemImage: item['image']!,
                    itemName: item['name']!,
                    price: item['price']!,
                    rating: item['rating']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleItemCard extends ConsumerStatefulWidget {
  final String specificItemImage;
  final String itemName;
  final String price;
  final String rating;

  const SingleItemCard({
    super.key,
    required this.specificItemImage,
    required this.itemName,
    required this.price,
    required this.rating,
  });

  @override
  ConsumerState<SingleItemCard> createState() => _SingleItemCardState();
}

class _SingleItemCardState extends ConsumerState<SingleItemCard> {
  bool isFavourite = false;

  void toggleFavourite() {
    setState(() {
      isFavourite = !isFavourite;
    });
  }

  double _parsePrice(String priceStr) {
    // Remove "Rs. " and any other non-numeric characters except dots
    final numericPart = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericPart) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.firstWhere(
      (item) => item.name == widget.itemName,
      orElse: () => CartItem(
        name: widget.itemName,
        image: widget.specificItemImage,
        price: _parsePrice(widget.price),
        quantity: 0,
      ),
    );

    final counter = cartItem.quantity;

    return Card(
      key: ValueKey(widget.itemName),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.specificItemImage,
                    height: 120, // Smaller image
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 400, // Optimize RAM usage
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 30),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, // Smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.rating,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _SmallCounterButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (counter > 0) {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(widget.itemName, counter - 1);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            counter.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _SmallCounterButton(
                          icon: Icons.add,
                          onPressed: () {
                            if (counter == 0) {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(cartItem.copyWith(quantity: 1));
                            } else {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(widget.itemName, counter + 1);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: toggleFavourite,
                child: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SmallCounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}

final List<Map<String, String>> singleItem = [
  {
    'name': 'Chicken Burger',
    'image': 'assets/food1.webp',
    'price': 'Rs. 500',
    'rating': '4.5',
  },
  {
    'name': 'Veg Burger',
    'image': 'assets/food2.webp',
    'price': 'Rs. 500',
    'rating': '3.5',
  },
  {
    'name': 'Buff Burger',
    'image': 'assets/food3.webp',
    'price': 'Rs. 500',
    'rating': '5.5',
  },
  {
    'name': 'Chicken Cheese Burger',
    'image': 'assets/food4.webp',
    'price': 'Rs. 100',
    'rating': '4.5',
  },
  {
    'name': 'Buff Cheese Burger',
    'image': 'assets/food2.webp',
    'price': 'Rs. 200',
    'rating': '3.5',
  },
  {
    'name': 'Chicken Double Patty Burger',
    'image': 'assets/food3.webp',
    'price': 'Rs. 300',
    'rating': '4.5',
  },
  {
    'name': 'Buff Double Patty Burger',
    'image': 'assets/food4.webp',
    'price': 'Rs. 400',
    'rating': '1.5',
  },
  {
    'name': 'Special Double Patty Chicken Burger',
    'image': 'assets/food5.webp',
    'price': 'Rs. 500',
    'rating': '2.5',
  },
  {
    'name': 'Chicken Burger',
    'image': 'assets/food6.webp',
    'price': 'Rs. 600',
    'rating': '8.5',
  },
];
