import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/explore/presentation/providers/recommended_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  final ExploreType type;
  const DiscoveryScreen({required this.type, super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalItems = ref.watch(cartTotalItemsProvider);

    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
    final cuisinesAsync = ref.watch(filteredCuisinesProvider);
    final recommendedAsync = ref.watch(recommendedItemsProvider);

    final currentAsync = widget.type == ExploreType.restaurant
        ? restaurantsAsync
        : (widget.type == ExploreType.food ? cuisinesAsync : recommendedAsync);

    final items = currentAsync.maybeWhen(
      data: (d) => d,
      orElse: () => currentAsync.value ?? [],
    );
    final isLoading = currentAsync is AsyncLoading;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF7F8FC),
      floatingActionButton: totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CartBottomSheet(),
                );
              },
              backgroundColor: colorScheme.primary,
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$totalItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: Text(
                AppLocalizations.of(context)!.viewCart,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: SearchableSliverAppLayout<dynamic>(
        title: widget.type == ExploreType.restaurant
            ? AppLocalizations.of(context)!.restaurants
            : (widget.type == ExploreType.food
                  ? AppLocalizations.of(context)!.cuisines
                  : AppLocalizations.of(context)!.recommended),
        expandedHeight: 0,
        hintText: widget.type == ExploreType.restaurant
            ? AppLocalizations.of(context)!.searchRestaurants
            : (widget.type == ExploreType.food
                  ? AppLocalizations.of(context)!.searchCuisines
                  : AppLocalizations.of(context)!.searchRecommended),
        items: items,
        isLoading: isLoading,
        filterPredicate: (item, query) {
          if (query.isEmpty) return true;
          final name = (item is RestaurantModel)
              ? item.name
              : (item is MenuItemModel ? item.name : '');
          final description = (item is RestaurantModel)
              ? item.description
              : (item is MenuItemModel ? item.description : '');

          return name.toLowerCase().contains(query.toLowerCase()) ||
              description.toLowerCase().contains(query.toLowerCase());
        },
        itemBuilder: (context, item, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: context.isMobile ? 2 : (context.isTablet ? 3 : 4),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: item is RestaurantModel
                    ? _buildRestaurantCard(item)
                    : _buildCuisineCard(item as MenuItemModel),
              ),
            ),
          );
        },
        skeleton: _buildLoadingState(),
        isGrid: true,
        isLoadingMore: _isLoadingMore,
        onLoadMore: () async {
          if (_isLoadingMore) return;

          bool hasMore = false;
          if (widget.type == ExploreType.restaurant) {
            hasMore = ref.read(filteredRestaurantsProvider.notifier).hasMore;
          } else if (widget.type == ExploreType.food) {
            hasMore = ref.read(filteredCuisinesProvider.notifier).hasMore;
          }

          if (!hasMore) return;

          setState(() => _isLoadingMore = true);
          try {
            if (widget.type == ExploreType.restaurant) {
              await ref.read(filteredRestaurantsProvider.notifier).loadMore();
            } else if (widget.type == ExploreType.food) {
              await ref.read(filteredCuisinesProvider.notifier).loadMore();
            }
          } finally {
            if (mounted) setState(() => _isLoadingMore = false);
          }
        },
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantModel restaurant) {
    final isFavourited = ref.watch(isFavouriteProvider(restaurant.id));

    return GestureDetector(
      onTap: () {
        context.push('/restaurantMenu', extra: restaurant);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AppImage(
                    imagePath: restaurant.bannerUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    type: AppImageType.thumbnail,
                  ),
                ),
                if (widget.type != ExploreType.restaurant)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.restaurant,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      await ref
                          .read(favouritesProvider.notifier)
                          .toggleFavourite(restaurant);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourited ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavourited ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Min - Max : Rs.${(restaurant.minOrderAmount > 0 ? restaurant.minOrderAmount : (Random().nextInt(1001) + 500)).toStringAsFixed(0)} - 1500',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineCard(MenuItemModel item) {
    final isFavourited = ref.watch(isFavouriteProvider(item.id));

    return GestureDetector(
      onTap: () {
        context.push('/cuisineSingleItem', extra: item);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AppImage(
                    imagePath: item.imageUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    type: AppImageType.menuItem,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      await ref
                          .read(favouritesProvider.notifier)
                          .toggleFavourite(item);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourited ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavourited ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (widget.type != ExploreType.food)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.food,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .addItem(
                                CartModel(
                                  id: item.id,
                                  name: item.name,
                                  price: item.price,
                                  image: item.imageUrl ?? '',
                                  quantity: 1,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.addedToCart(item.name),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            size: 16,
                            color: Colors.white,
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

  Widget _buildLoadingState() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ShimmerPlaceholder(
          height: 200,
          width: double.infinity,
        ),
        childCount: 6,
      ),
    );
  }
}
