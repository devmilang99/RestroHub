import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';

class SliverOfferCards extends StatefulWidget {
  final String headingTitle;
  final List<MenuItemModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverOfferCards({
    required this.headingTitle,
    required this.items,
    super.key,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  State<SliverOfferCards> createState() => _SliverOfferCardsState();
}

class _SliverOfferCardsState extends State<SliverOfferCards> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.items.isEmpty) return;
      if (_currentPage < widget.items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayItems = widget.displayCount != null
        ? widget.items.take(widget.displayCount!).toList()
        : widget.items;

    if (displayItems.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () =>
                          context.pushNamed('cuisineSingleItem', extra: item),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            const Positioned(
                              right: -20,
                              bottom: -20,
                              child: Opacity(
                                opacity: 0.2,
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  size: 150,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'HOT DEAL',
                                            style: GoogleFonts.poppins(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          item.name,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Order now and save!',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child:
                                          (item.imageUrl?.startsWith('http') ??
                                              false)
                                          ? Image.network(
                                              item.imageUrl!,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white,
                                                  ),
                                            )
                                          : Image.asset(
                                              item.imageUrl ?? '',
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.fastfood,
                                                    color: Colors.white,
                                                    size: 40,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                displayItems.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? colorScheme.primary
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliverRestaurantCards extends StatelessWidget {
  final String headingTitle;
  final List<RestaurantModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverRestaurantCards({
    required this.headingTitle,
    required this.items,
    super.key,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;

    final isWide = context.isWide;
    final cardWidth = isWide ? 280.0 : 220.0;
    final containerHeight = isWide ? 240.0 : 200.0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () =>
                          context.pushNamed('exploreRestaurantsScreen'),
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: containerHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final r = displayItems[index];
                  return GestureDetector(
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RestaurantMenuScreen(restaurant: r),
                      ),
                    ),
                    child: RepaintBoundary(
                      child: Container(
                        width: cardWidth,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                )
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.07),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (r.logoUrl?.startsWith('http') ?? false)
                              Image.network(
                                r.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image),
                              )
                            else
                              Image.asset(
                                r.logoUrl ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.restaurant, size: 40),
                              ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black87],
                                  stops: [0.4, 1.0],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        r.rating.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.white70,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 3),
                                      const Text(
                                        '30 min',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
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
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverFoodCards extends ConsumerWidget {
  final String headingTitle;
  final List<MenuItemModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverFoodCards({
    required this.headingTitle,
    required this.items,
    super.key,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;

    final isWide = context.isWide;
    final cardWidth = isWide ? 200.0 : 160.0;
    final containerHeight = isWide ? 260.0 : 220.0;

    ref.watch(favouritesProvider); // Rebuild when favorites change

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () => context.pushNamed(
                        'allCuisineList',
                        extra: {'title': headingTitle, 'items': items},
                      ),
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: containerHeight + 60, // Increased for buttons
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final isFav = ref
                      .read(favouritesProvider.notifier)
                      .isFavourite(item);

                  return GestureDetector(
                    onTap: () async {
                      final restaurantId = await ref.read(
                        restaurantIdFromCategoryProvider(
                          item.categoryId,
                        ).future,
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
                                builder: (_) => RestaurantMenuScreen(
                                  restaurant: restaurant,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : [
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
                                if (item.imageUrl?.startsWith('http') ?? false)
                                  Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.broken_image,
                                    ),
                                  )
                                else
                                  Image.asset(
                                    item.imageUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.fastfood,
                                      size: 40,
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(favouritesProvider.notifier)
                                          .toggleFavourite(item);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 16,
                                        color: isFav
                                            ? Colors.red
                                            : colorScheme.primary,
                                      ),
                                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs. ${item.price.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final cartItem = CartModel(
                                          id: item.id ?? item.name,
                                          name: item.name,
                                          image: item.imageUrl ?? '',
                                          price: item.price,
                                          quantity: 1,
                                        );
                                        ref
                                            .read(cartProvider.notifier)
                                            .addItem(cartItem);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${item.name} added to cart',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
