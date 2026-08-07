import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_skeletons.dart';
import 'package:restro_hub/features/favourites/data/models/favourite_item.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';

final favouriteSearchProvider = StateProvider<String>((ref) => '');

class ShowFavourites extends ConsumerWidget {
  const ShowFavourites({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouritesProvider);
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: favsAsync.when(
        data: (favs) {
          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          return _FavouritesList(favs: favs);
        },
        loading: () => const CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverListSkeleton(itemCount: 5),
            ),
          ],
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _FavouritesList extends ConsumerWidget {
  final List<FavouriteItem> favs;
  const _FavouritesList({required this.favs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(favouriteSearchProvider);

    final filtered = favs.where((item) {
      return item.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty && searchQuery.isNotEmpty) {
      return const Center(
        child: Text('No matching favorites found'),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: item is RestaurantFavourite
                    ? _RestaurantFavouriteCard(
                        item: item,
                        onRemove: () {
                          unawaited(
                            ref
                                .read(favouritesProvider.notifier)
                                .toggleFavourite(item),
                          );
                        },
                      )
                    : _MenuItemFavouriteCard(
                        item: item as MenuItemFavourite,
                        onRemove: () {
                          unawaited(
                            ref
                                .read(favouritesProvider.notifier)
                                .toggleFavourite(item),
                          );
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantFavouriteCard extends StatelessWidget {
  final RestaurantFavourite item;
  final VoidCallback onRemove;

  const _RestaurantFavouriteCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final restaurant = item.restaurant;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF1A1F24) : colorScheme.surface;
    final highlightColor = isDark
        ? const Color(0xFFFFB74D)
        : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Hero(
              tag: 'restaurant_${restaurant.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AppImage(
                    imagePath: restaurant.logoUrl ?? '',
                    width: 100,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        restaurant.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: highlightColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12, color: highlightColor),
                            const SizedBox(width: 2),
                            Text(
                              restaurant.rating.toString(),
                              style: textTheme.labelSmall?.copyWith(
                                color: highlightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: highlightColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.locationAddress ?? 'No address',
                          style: textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? Colors.white60
                                : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemFavouriteCard extends ConsumerWidget {
  final MenuItemFavourite item;
  final VoidCallback onRemove;

  const _MenuItemFavouriteCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final menuItem = item.menuItem;
    final restaurant = item.restaurant;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use dark colors from image if possible, or theme colors
    final cardBgColor = isDark ? const Color(0xFF1A1F24) : colorScheme.surface;
    final highlightColor = isDark
        ? const Color(0xFFFFB74D)
        : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Restaurant Info & Heart
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storefront, size: 14, color: highlightColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  restaurant?.name ?? 'Restaurant',
                  style: textTheme.labelLarge?.copyWith(
                    color: isDark ? highlightColor : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Middle Row: Image & Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              Hero(
                tag: 'food_${menuItem.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AppImage(
                      imagePath: menuItem.imageUrl ?? '',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : colorScheme.onSurface,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      menuItem.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rs. ${menuItem.price.toStringAsFixed(0)}',
                      style: textTheme.headlineSmall?.copyWith(
                        color: isDark ? highlightColor : colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bottom Row: Stats & Add to Cart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                icon: Icons.star_rounded,
                label: menuItem.rating.toStringAsFixed(1),
                color: highlightColor,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.access_time_rounded,
                label: '25 min',
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.location_on_outlined,
                label: '1.2 km',
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                isDark: isDark,
              ),
              GestureDetector(
                onTap: () async {
                  final cartItem = CartModel(
                    id: menuItem.id ?? menuItem.name,
                    name: menuItem.name,
                    image: menuItem.imageUrl ?? '',
                    price: menuItem.price,
                    quantity: 1,
                    restaurantId: menuItem.categoryId, // Fallback
                  );
                  await ref.read(cartProvider.notifier).addItem(cartItem);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${menuItem.name} added to cart'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: highlightColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: highlightColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.add_shopping_cart_rounded,
                    color: highlightColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
