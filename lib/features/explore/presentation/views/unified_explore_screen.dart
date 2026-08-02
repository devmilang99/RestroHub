import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';

class UnifiedExploreScreen extends ConsumerStatefulWidget {
  final ExploreType type;
  const UnifiedExploreScreen({required this.type, super.key});

  @override
  ConsumerState<UnifiedExploreScreen> createState() =>
      _UnifiedExploreScreenState();
}

class _UnifiedExploreScreenState extends ConsumerState<UnifiedExploreScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final totalItems = ref.watch(cartTotalItemsProvider);

    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
    final cuisinesAsync = ref.watch(allCuisinesStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF7F8FC),
      floatingActionButton: totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      const CartBottomSheet(isInsideModal: true),
                );
              },
              label: Text('$totalItems items'),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
      body: _buildExploreView(restaurantsAsync, cuisinesAsync),
    );
  }

  Widget _buildExploreView(
    AsyncValue<List<RestaurantModel>> restaurantsAsync,
    AsyncValue<List<MenuItemModel>> cuisinesAsync,
  ) {
    final colorScheme = context.colorScheme;

    // Combine data for Recommended type
    List<dynamic> items = [];
    if (widget.type == ExploreType.restaurant) {
      items = restaurantsAsync.value ?? [];
    } else if (widget.type == ExploreType.food) {
      items = cuisinesAsync.value ?? [];
    } else {
      // Recommended: 4.5+ stars for both
      final highRatedRestaurants = (restaurantsAsync.value ?? [])
          .where((r) => r.rating >= 4.5)
          .toList();
      final highRatedFood = (cuisinesAsync.value ?? [])
          .where((f) => f.rating >= 4.5)
          .toList();

      // Interleave for a varied grid
      int i = 0, j = 0;
      while (i < highRatedRestaurants.length || j < highRatedFood.length) {
        if (i < highRatedRestaurants.length)
          items.add(highRatedRestaurants[i++]);
        if (j < highRatedFood.length) items.add(highRatedFood[j++]);
      }
    }

    return SearchableSliverAppLayout<dynamic>(
      title: widget.type == ExploreType.recommended
          ? 'Recommended'
          : (widget.type == ExploreType.restaurant
                ? 'Restaurants'
                : 'Cuisines'),
      items: items,
      hintText: 'Search...',
      onBackPressed: () => context.pop(),
      onSearchChanged: (query) => setState(() => _query = query),
      filterPredicate: (item, query) {
        if (item is RestaurantModel) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase());
        } else if (item is MenuItemModel) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase());
        }
        return false;
      },
      isGrid: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 2 : (context.isTablet ? 3 : 4),
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, item, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: context.isMobile ? 2 : (context.isTablet ? 3 : 4),
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: item is RestaurantModel
                  ? _UnifiedRestaurantCard(restaurant: item)
                  : _UnifiedFoodCard(item: item as MenuItemModel),
            ),
          ),
        );
      },
      background: _buildBackground(colorScheme),
    );
  }

  Widget _buildBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.type == ExploreType.restaurant
                  ? Icons.restaurant
                  : (widget.type == ExploreType.food
                        ? Icons.fastfood
                        : Icons.stars),
              size: 60,
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Explore Best Options',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnifiedRestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  const _UnifiedRestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => RestaurantMenuScreen(restaurant: restaurant),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (restaurant.logoUrl?.startsWith('assets') ?? false)
                      ? Image.asset(restaurant.logoUrl!, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: restaurant.logoUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerPlaceholder(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _RatingBadge(rating: restaurant.rating),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _TypeBadge(
                      label: 'Restaurant',
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.description,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnifiedFoodCard extends ConsumerWidget {
  final MenuItemModel item;
  const _UnifiedFoodCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isFav = ref.watch(favouritesProvider.notifier).isFavourite(item);
    ref.watch(favouritesProvider);

    return GestureDetector(
      onTap: () async {
        await context.pushNamed('cuisineSingleItem', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (item.imageUrl?.startsWith('assets') ?? false)
                      ? Image.asset(item.imageUrl!, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: item.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerPlaceholder(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(favouritesProvider.notifier)
                            .toggleFavourite(item);
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _RatingBadge(rating: item.rating),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _TypeBadge(
                      label: 'Food',
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final cartItem = CartModel(
                            id: item.id ?? item.name,
                            name: item.name,
                            image: item.imageUrl ?? '',
                            price: item.price,
                            quantity: 1,
                          );
                          await ref
                              .read(cartProvider.notifier)
                              .addItem(cartItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          const SizedBox(width: 2),
          Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
