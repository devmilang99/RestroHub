import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart'
    as cart_model;
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortBy = 'name'; // 'name', 'price_asc', 'price_desc'
  double _minRating = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort & Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sort By',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [
                      FilterChip(
                        label: const Text('Name'),
                        selected: _sortBy == 'name',
                        onSelected: (val) {
                          setState(() => _sortBy = 'name');
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Price: Low to High'),
                        selected: _sortBy == 'price_asc',
                        onSelected: (val) {
                          setState(() => _sortBy = 'price_asc');
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Price: High to Low'),
                        selected: _sortBy == 'price_desc',
                        onSelected: (val) {
                          setState(() => _sortBy = 'price_desc');
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Minimum Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [0.0, 3.0, 4.0, 4.5].map((rating) {
                      return FilterChip(
                        label: Text(rating == 0.0 ? 'All' : '$rating+ ★'),
                        selected: _minRating == rating,
                        onSelected: (val) {
                          setState(() => _minRating = rating);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getFilterLabel() {
    final filters = <String>[];
    if (_sortBy != 'name') {
      if (_sortBy == 'price_asc') {
        filters.add('Price: Low to High');
      } else if (_sortBy == 'price_desc') {
        filters.add('Price: High to Low');
      }
    }
    if (_minRating > 0.0) {
      filters.add('Rating: $_minRating+ ★');
    }
    return filters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final allCuisinesAsync = ref.watch(allCuisinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Badge(
              isLabelVisible: _sortBy != 'name' || _minRating > 0.0,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_sortBy != 'name' || _minRating > 0.0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.close, size: 14),
                    label: Text(
                      _getFilterLabel(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _sortBy = 'name';
                        _minRating = 0.0;
                      });
                    },
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          Expanded(
            child: allCuisinesAsync.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  final matchesQuery =
                      item.name.toLowerCase().contains(_query.toLowerCase()) ||
                      item.description.toLowerCase().contains(
                        _query.toLowerCase(),
                      );
                  // Mock rating for items if not present (as per requirement)
                  const itemRating = 4.5;
                  return matchesQuery && itemRating >= _minRating;
                }).toList();

                // Sort
                if (_sortBy == 'name') {
                  filteredItems.sort((a, b) => a.name.compareTo(b.name));
                } else if (_sortBy == 'price_asc') {
                  filteredItems.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortBy == 'price_desc') {
                  filteredItems.sort((a, b) => b.price.compareTo(a.price));
                }

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No food items found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: SearchFoodCard(item: item),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchFoodCard extends ConsumerWidget {
  final MenuItemModel item;
  const SearchFoodCard({required this.item, super.key});

  Future<void> _navigateToRestaurant(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final restaurantId = await ref.read(
      restaurantIdFromCategoryProvider(item.categoryId).future,
    );
    if (restaurantId != null) {
      final restaurant = await ref.read(
        restaurantFromIdProvider(restaurantId).future,
      );
      if (restaurant != null && context.mounted) {
        unawaited(
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => RestaurantMenuScreen(restaurant: restaurant),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final restaurantAsync = ref.watch(
      restaurantFromCategoryIdProvider(item.categoryId),
    );

    return GestureDetector(
      onTap: () async {
        await _navigateToRestaurant(context, ref);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (restaurantAsync.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurantAsync.value!.name,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: (item.imageUrl?.startsWith('assets') ?? false)
                          ? Image.asset(
                              item.imageUrl!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: item.imageUrl ?? '',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const ShimmerPlaceholder(
                                    width: 100,
                                    height: 100,
                                  ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.fastfood),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final isFavourited = ref.watch(
                            isFavouriteProvider(item.id),
                          );
                          return GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(favouritesProvider.notifier)
                                  .toggleFavourite(item);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavourited
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 14,
                                color: isFavourited ? Colors.red : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rs. ${item.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '4.5',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            // Time
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.grey,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '25 min',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            // Distance
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '1.2 km',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            // Cart Action
                            Material(
                              color: colorScheme.primaryContainer.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () async {
                                  final cartItem = cart_model.CartModel(
                                    id: item.id ?? item.name,
                                    name: item.name,
                                    image: item.imageUrl ?? '',
                                    price: item.price,
                                    quantity: 1,
                                  );
                                  await ref
                                      .read(cartProvider.notifier)
                                      .addItem(cartItem);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.name} added to cart',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
