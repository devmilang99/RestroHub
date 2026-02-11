import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restro_hub/core/providers/cart_provider.dart';
import 'package:restro_hub/core/widgets/cart_bottom_sheet.dart';

import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/login/screens/Cuisine/cuisine_Single_item.dart';

class AllCousineList extends ConsumerWidget {
  const AllCousineList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final cart = ref.watch(cartProvider);
    final totalItems = cart.fold(0, (sum, item) => sum + item.quantity);
    final totalAmount = cart.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: const Text('Cuisine'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Cuisines",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ExploreItemsMainCard(
            headingTitle: "Italian",
            isHorizontal: true,
            items: cuisines,
            hasOffer: true,
            offerPercent: "10%",
            rating: "4.5",
          ),
        ],
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CartBottomSheet(),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                "$totalItems items | Rs. ${totalAmount.toStringAsFixed(0)}",
              ),
            )
          : null,
    );
  }
}

final List<Map<String, String>> cuisines = [
  {
    'name': 'Italian',
    'image': 'assets/food1.webp',
    'rating': '4.5',
    'offerPercent': '10%',
  },
  {
    'name': 'Chinese',
    'image': 'assets/food2.webp',
    'rating': '4.5',
    'offerPercent': '20%',
  },
  {
    'name': 'Mexican',
    'image': 'assets/food3.webp',
    'rating': '4.5',
    'offerPercent': '30%',
  },
  {
    'name': 'Indian',
    'image': 'assets/food4.webp',
    'rating': '4.5',
    'offerPercent': '40%',
  },
  {
    'name': 'Thai',
    'image': 'assets/food5.webp',
    'rating': '4.5',
    'offerPercent': '50%',
  },
];

class ExploreItemsMainCard extends StatelessWidget {
  final String headingTitle;
  final bool hasOffer;
  final bool isHorizontal;
  final String offerPercent;
  final String rating;
  final List<Map<String, String>> items;
  const ExploreItemsMainCard({
    super.key,
    required this.headingTitle,
    required this.hasOffer,
    required this.isHorizontal,
    required this.offerPercent,
    required this.rating,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      key: Key(headingTitle),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ExploreItemsList(
              name: items[index]['name']!,
              image: items[index]['image']!,
              rating: rating,
              offerPercent: offerPercent,
              onClick: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CuisineSingleItem(id: items[index]['name']!);
                  },
                );
                // context.push('/cuisineSingleItem/${items[index]['name']}');
              },
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class ExploreItemsList extends StatelessWidget {
  final String name;
  final String image;
  final String rating;
  final String offerPercent;
  final Function onClick;
  const ExploreItemsList({
    super.key,
    required this.name,
    required this.image,
    required this.rating,
    required this.offerPercent,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    bool isNetwork = image.startsWith('http');
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(height: 200, color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Image.asset(
                        image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 600, // Optimized RAM loading
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(" $rating"),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Flat $offerPercent OFF",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
