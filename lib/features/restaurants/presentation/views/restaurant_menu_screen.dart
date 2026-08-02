import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/utils/launcher_utils.dart';
import 'package:restro_hub/core/widgets/circle_button.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/core/widgets/share_bottom_sheet.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/data/repositories/cuisine_repository.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/data/models/review_model.dart';

class RestaurantMenuScreen extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantMenuScreen({required this.restaurant, super.key});

  @override
  ConsumerState<RestaurantMenuScreen> createState() =>
      _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends ConsumerState<RestaurantMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isCollapsed = false;
  String _selectedReviewFilter = 'All';

  final List<ReviewModel> _mockReviews = [
    const ReviewModel(
      name: 'Alex Rivera',
      rating: 5,
      time: '2 days ago',
      comment:
          'The food was absolutely delicious! Especially the pasta was so creamy and flavorful. Must try for everyone.',
      images: [
        'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
      ],
    ),
    const ReviewModel(
      name: 'Mia Thompson',
      rating: 4,
      time: '5 days ago',
      comment:
          'Great service and ambiance. The pizza was fresh and hot, exactly how I like it. Will come back for sure!',
      images: [],
    ),
    const ReviewModel(
      name: 'James Wilson',
      rating: 4.5,
      time: '1 week ago',
      comment:
          'Amazing place for family dinner. The dessert menu is a must-try! Highly recommended for weekend vibes.',
      images: [],
    ),
  ];

  List<ReviewModel> get _filteredReviews {
    if (_selectedReviewFilter == 'All') return _mockReviews;
    final rating = double.tryParse(_selectedReviewFilter) ?? 0.0;
    return _mockReviews
        .where((r) => r.rating >= rating && r.rating < rating + 1.0)
        .toList();
  }
  // Note: restaurant favorites will be mirrored into the global favourites
  // list by creating a lightweight `MenuItemModel` from the restaurant.

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _searchQuery = _searchController.text.toLowerCase());
        }
      });
    });
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > (320 - kToolbarHeight);
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<MenuItemModel> _getFilteredMenu(List<MenuItemModel> menu) {
    if (_searchQuery.isEmpty) return menu;
    return menu
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery) ||
              item.description.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void _showWriteReviewSheet(
    BuildContext context, {
    ReviewModel? editReview,
    int? index,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _WriteReviewSheet(
          restaurantName: widget.restaurant.name,
          initialRating: editReview?.rating.toInt(),
          initialComment: editReview?.comment,
          onSubmit: (newReviewMap) {
            final newReview = ReviewModel.fromJson(newReviewMap);
            setState(() {
              if (index != null) {
                _mockReviews[index] = ReviewModel(
                  name: _mockReviews[index].name,
                  rating: newReview.rating,
                  time: 'Edited • Just now',
                  comment: newReview.comment,
                  images: newReview.images,
                );
              } else {
                _mockReviews.insert(0, newReview);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.restaurant;

    final menuAsync = r.id != null
        ? ref.watch(cuisineRepositoryProvider).watchCuisines(r.id!)
        : Stream.value(r.categories.expand((c) => c.items).toList());

    final favItem = MenuItemModel(
      id: r.id,
      categoryId: '',
      name: r.name,
      description: r.description,
      imageUrl: r.logoUrl,
      price: 0,
    );

    final isFav = ref.watch(isFavouriteProvider(r.id));

    return StreamBuilder<List<MenuItemModel>>(
      stream: menuAsync,
      initialData: r.categories.expand((c) => c.items).toList(),
      builder: (context, snapshot) {
        final menu = _getFilteredMenu(snapshot.data ?? []);
        final isWide = context.isWide;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          floatingActionButton: (ref.watch(cartProvider).value ?? []).isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    unawaited(
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            const CartBottomSheet(isInsideModal: true),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
                  label: Text(
                    '${ref.watch(cartTotalItemsProvider)} items',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  backgroundColor: colorScheme.primary,
                )
              : null,
          body: ResponsiveCenter(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero image app bar ─────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: isWide ? 400 : 320,
                  pinned: true,
                  stretch: true,
                  backgroundColor: colorScheme.surface,
                  elevation: 0,
                  centerTitle: true,
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isCollapsed ? 1.0 : 0.0,
                    child: Text(
                      r.name,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Consumer(
                        builder: (context, ref, child) {
                          return CircleButton(
                            icon: isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: Colors.red,
                            onTap: () => unawaited(
                              ref
                                  .read(favouritesProvider.notifier)
                                  .toggleFavourite(favItem, isRestaurant: true),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: CircleButton(
                        icon: Icons.phone_rounded,
                        onTap: () =>
                            LauncherUtils.launchPhone('+9779800000000'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 12,
                        top: 8,
                        bottom: 8,
                      ),
                      child: CircleButton(
                        icon: Icons.share_rounded,
                        onTap: () {
                          ShareBottomSheet.show(
                            context,
                            title: r.name,
                            shareLink:
                                "restrohub://restaurant/${r.name.toLowerCase().replaceAll(' ', '_')}",
                          );
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'restaurant_${r.name}',
                          child: (r.logoUrl?.startsWith('assets') ?? false)
                              ? Image.asset(r.logoUrl!, fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: r.logoUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // gradient overlay for readability
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black26,
                                Colors.transparent,
                                Colors.black54,
                              ],
                              stops: [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Info card (white sheet over image) ─────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // name + rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                r.name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      color: Colors.amber.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // meta chips row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _MetaChip(
                              icon: Icons.location_on_rounded,
                              label: (r.locationAddress ?? 'Various')
                                  .split(',')
                                  .first,
                              color: colorScheme.primary,
                            ),
                            const _MetaChip(
                              icon: Icons.access_time_filled_rounded,
                              label: '30 min',
                              color: Colors.orange,
                            ),
                            if (r.minOrderAmount > 0)
                              _MetaChip(
                                icon: Icons.payments_rounded,
                                label:
                                    'Min Rs. ${r.minOrderAmount.toStringAsFixed(0)}',
                                color: Colors.green,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // description
                        Text(
                          r.description,
                          style: GoogleFonts.poppins(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.58,
                            ),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Menu Search ──
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Text(
                          'Menu',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                      .withValues(
                                        alpha: 0.3,
                                      )
                                : const Color(0xFFF3F4F8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search in menu…',
                              hintStyle: GoogleFonts.poppins(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),
                        if (menu.isEmpty) ...[
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No items found',
                                  style: GoogleFonts.poppins(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.35,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Menu items content ────────────────────────────────────────────
                if (menu.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: AnimationLimiter(
                      child: isWide
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.8,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: const Duration(
                                        milliseconds: 375,
                                      ),
                                      columnCount: 2,
                                      child: SlideAnimation(
                                        verticalOffset: 50,
                                        child: FadeInAnimation(
                                          child: _MenuItemCard(
                                            item: menu[index],
                                            index: index,
                                            isFirst: index == 0,
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                          ),
                                        ),
                                      ),
                                    ),
                                childCount: menu.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(
                                        milliseconds: 375,
                                      ),
                                      child: SlideAnimation(
                                        verticalOffset: 50,
                                        child: FadeInAnimation(
                                          child: _MenuItemCard(
                                            item: menu[index],
                                            index: index,
                                            isFirst: index == 0,
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                          ),
                                        ),
                                      ),
                                    ),
                                childCount: menu.length,
                              ),
                            ),
                    ),
                  ),

                // ── Reviews Section ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showWriteReviewSheet(context),
                              icon: Icon(
                                Icons.rate_review_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                'Rate & Review',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Review Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', '5.0', '4.0', '3.0', '2.0'].map((
                              filter,
                            ) {
                              final isSelected =
                                  _selectedReviewFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    filter == 'All'
                                        ? 'All Reviews'
                                        : '$filter ★',
                                  ),
                                  selected: isSelected,
                                  onSelected: (val) => setState(
                                    () => _selectedReviewFilter = filter,
                                  ),
                                  backgroundColor: colorScheme.surface,
                                  selectedColor: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: isWide
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final review = _filteredReviews[index];
                            return _ReviewCard(
                              index: index,
                              name: review.name,
                              rating: review.rating,
                              time: review.time,
                              comment: review.comment,
                              images: review.images,
                              onEdit: () => _showWriteReviewSheet(
                                context,
                                editReview: review,
                                index: _mockReviews.indexOf(review),
                              ),
                              onDelete: () {
                                setState(() {
                                  _mockReviews.remove(review);
                                });
                              },
                            );
                          }, childCount: _filteredReviews.length),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final review = _filteredReviews[index];
                            return _ReviewCard(
                              index: index,
                              name: review.name,
                              rating: review.rating,
                              time: review.time,
                              comment: review.comment,
                              images: review.images,
                              onEdit: () => _showWriteReviewSheet(
                                context,
                                editReview: review,
                                index: _mockReviews.indexOf(review),
                              ),
                              onDelete: () {
                                setState(() {
                                  _mockReviews.remove(review);
                                });
                              },
                            );
                          }, childCount: _filteredReviews.length),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Menu item card with staggered entrance animation ─────────────────────────
class _MenuItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final int index;
  final bool isFirst;
  final bool isDark;
  final ColorScheme colorScheme;

  const _MenuItemCard({
    required this.item,
    required this.index,
    required this.isFirst,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;

    return GestureDetector(
      onTap: () => context.pushNamed('cuisineSingleItem', extra: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.12 : 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // thumbnail
            Card(
              elevation: 0,
              child: Hero(
                tag: 'food_${item.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: (item.imageUrl?.startsWith('assets') ?? false)
                      ? Image.asset(
                          item.imageUrl!,
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: item.imageUrl ?? '',
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.black12,
            ),
            // details
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // badge (signature for first item)
                        if (isFirst)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Best Dish',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Favourite Icon
                        Consumer(
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
                                child: Icon(
                                  isFavourited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFavourited
                                      ? Colors.red
                                      : cs.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // name
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // description
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // price + add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${item.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            fontSize: 16,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
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
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                color: cs.primary,
                                size: 20,
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
      ),
    );
  }
}

// ── Reusable meta chip ────────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final String name;
  final double rating;
  final String time;
  final String comment;
  final List<String> images;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.index,
    required this.name,
    required this.rating,
    required this.time,
    required this.comment,
    required this.images,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=user$index',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (name == 'You') ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit?.call();
                    }
                    if (val == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: cs.error,
                          ),
                          const SizedBox(width: 8),
                          const Text('Delete', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _openImageSlider(context, images, i),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(images[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageSlider(BuildContext context, List<String> images, int index) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: Colors.black,
        builder: (context) =>
            _ImageSliderDialog(images: images, initialIndex: index),
      ),
    );
  }
}

class _ImageSliderDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _ImageSliderDialog({required this.images, required this.initialIndex});

  @override
  State<_ImageSliderDialog> createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<_ImageSliderDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == i ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String restaurantName;
  final void Function(Map<String, dynamic>) onSubmit;
  final int? initialRating;
  final String? initialComment;

  const _WriteReviewSheet({
    required this.restaurantName,
    required this.onSubmit,
    this.initialRating,
    this.initialComment,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } on Exception catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
      padding: EdgeInsets.fromLTRB(24, 20, 24, mq.viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rate your experience at',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              widget.restaurantName,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starValue <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Write a Review',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell us what you liked or disliked...',
                hintStyle: GoogleFonts.poppins(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Add Photos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                ),
              ],
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newReview = {
                    'name': 'You',
                    'rating': _rating.toDouble(),
                    'time': 'Just now',
                    'comment': _commentController.text.isEmpty
                        ? 'Excellent experience!'
                        : _commentController.text,
                    'images': [
                      'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop',
                    ], // Mocking image submission
                  };
                  widget.onSubmit(newReview);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your valuable feedback!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Review',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
