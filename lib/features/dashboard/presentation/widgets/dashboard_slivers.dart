import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/enums.dart';
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

    if (displayItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

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
                    child: RepaintBoundary(
                      child: GestureDetector(
                        onTap: () async {
                          await context.pushNamed(
                            'cuisineSingleItem',
                            extra: item,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Image covering the entire card
                              if (item.imageUrl?.startsWith('http') ?? false) Image.network(
                                      item.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => ColoredBox(
                                        color: colorScheme.primary,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ) else Image.asset(
                                      item.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => ColoredBox(
                                        color: colorScheme.primary,
                                        child: const Icon(
                                          Icons.fastfood,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                              // Dark gradient overlay for text readability
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black87,
                                    ],
                                    stops: [0.3, 1.0],
                                  ),
                                ),
                              ),
                              // Layered text above the picture
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child: Text(
                                        'HOT DEAL',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
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
                            ],
                          ),
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

class SliverRestaurantCards extends ConsumerWidget {
  final String headingTitle;
  final List<dynamic> items;
  final int? displayCount;
  final bool seeAll;
  final IconData? titleIcon;
  final ExploreType exploreType;

  const SliverRestaurantCards({
    required this.headingTitle,
    required this.items,
    super.key,
    this.displayCount,
    this.seeAll = false,
    this.titleIcon,
    this.exploreType = ExploreType.restaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (titleIcon != null) ...[
                        Icon(titleIcon, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        headingTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () async {
                        await context.pushNamed(
                          'unifiedExplore',
                          extra: exploreType,
                        );
                      },
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
            SizedBox(
              height: containerHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  var name = '';
                  String? imageUrl = '';
                  double rating = 0.0;
                  Future<void> Function()? onTap;

                  if (item is RestaurantModel) {
                    name = item.name;
                    imageUrl = item.logoUrl;
                    rating = item.rating;
                    onTap = () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RestaurantMenuScreen(restaurant: item),
                        ),
                      );
                    };
                  } else if (item is MenuItemModel) {
                    name = item.name;
                    imageUrl = item.imageUrl;
                    rating = item.rating;
                    onTap = () async {
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
                    };
                  }

                  return RepaintBoundary(
                    child: GestureDetector(
                      onTap: onTap,
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
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl?.startsWith('http') ?? false)
                              Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image),
                              )
                            else
                              Image.asset(
                                imageUrl ?? '',
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
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item is RestaurantModel
                                      ? 'RESTAURANT'
                                      : 'FOOD',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final itemId = item is RestaurantModel
                                      ? item.id
                                      : (item as MenuItemModel).id;
                                  final isFav = ref.watch(
                                    isFavouriteProvider(itemId),
                                  );
                                  return GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      final favItem = item is RestaurantModel
                                          ? MenuItemModel(
                                              id: item.id,
                                              categoryId: '',
                                              name: item.name,
                                              description: item.description,
                                              price: 0,
                                              imageUrl: item.logoUrl,
                                            )
                                          : item as MenuItemModel;
                                      await ref
                                          .read(favouritesProvider.notifier)
                                          .toggleFavourite(
                                            favItem,
                                            isRestaurant:
                                                item is RestaurantModel,
                                          );
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
                                        size: 14,
                                        color: isFav ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
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
                                    name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item is MenuItemModel)
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final restaurantAsync = ref.watch(
                                          restaurantFromCategoryIdProvider(
                                            item.categoryId,
                                          ),
                                        );
                                        return restaurantAsync.when(
                                          data: (r) => r != null
                                              ? Text(
                                                  r.name,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : const SizedBox.shrink(),
                                          loading: () =>
                                              const SizedBox.shrink(),
                                          error: (_, _) =>
                                              const SizedBox.shrink(),
                                        );
                                      },
                                    ),
                                  if (item is RestaurantModel &&
                                      item.locationAddress != null)
                                    Text(
                                      item.locationAddress!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
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
                                        rating.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (item is RestaurantModel &&
                                          item.minOrderAmount > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          'Min Rs. ${item.minOrderAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            color: colorScheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
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
          ],
        ),
      ),
    );
  }
}

class SliverFoodCards extends ConsumerWidget {
  final String headingTitle;
  final List<MenuItemModel> items;
  final int? displayCount;
  final bool seeAll;
  final IconData? titleIcon;
  final ExploreType exploreType;

  const SliverFoodCards({
    required this.headingTitle,
    required this.items,
    super.key,
    this.displayCount,
    this.seeAll = false,
    this.titleIcon,
    this.exploreType = ExploreType.food,
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (titleIcon != null) ...[
                        Icon(titleIcon, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        headingTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () async {
                        await context.pushNamed(
                          'unifiedExplore',
                          extra: exploreType,
                        );
                      },
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
            SizedBox(
              height: containerHeight + 60, // Increased for buttons
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];

                  return RepaintBoundary(
                    child: GestureDetector(
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
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (item.imageUrl?.startsWith('http') ??
                                      false)
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
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final isFav = ref.watch(
                                          isFavouriteProvider(item.id),
                                        );
                                        return GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            await ref
                                                .read(
                                                  favouritesProvider.notifier,
                                                )
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
                                        );
                                      },
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
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.rating.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
                                            Icons.shopping_cart,
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
                    ),
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
