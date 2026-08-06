import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/utils/launcher_utils.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/core/widgets/circle_button.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/core/widgets/share_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/mock_reviews.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/data/models/review_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/widgets/menu_item_card.dart';
import 'package:restro_hub/features/restaurants/presentation/widgets/meta_chip.dart';
import 'package:restro_hub/features/restaurants/presentation/widgets/review_card.dart';
import 'package:restro_hub/features/restaurants/presentation/widgets/write_review_sheet.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

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
  late final List<ReviewModel> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(mockReviews);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ReviewModel> get _filteredReviews {
    if (_selectedReviewFilter == 'All') return _reviews;
    final rating = double.tryParse(_selectedReviewFilter) ?? 0.0;
    return _reviews
        .where((r) => r.rating >= rating && r.rating < rating + 1.0)
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
        builder: (context) => WriteReviewSheet(
          restaurantName: widget.restaurant.name,
          initialRating: editReview?.rating.toInt(),
          initialComment: editReview?.comment,
          onSubmit: (newReviewMap) {
            final newReview = ReviewModel.fromJson(newReviewMap);
            setState(() {
              if (index != null) {
                _reviews[index] = ReviewModel(
                  name: _reviews[index].name,
                  rating: newReview.rating,
                  time: 'Edited • Just now',
                  comment: newReview.comment,
                  images: newReview.images,
                );
              } else {
                _reviews.insert(0, newReview);
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
    final l10n = AppLocalizations.of(context)!;

    // Watch for live restaurant updates from the database
    final AsyncValue<RestaurantModel?> restaurantAsync =
        widget.restaurant.id != null
        ? ref.watch(restaurantDetailProvider(widget.restaurant.id!))
        : AsyncValue.data(widget.restaurant);

    final r = restaurantAsync.value ?? widget.restaurant;

    final AsyncValue<List<MenuItemModel>> menuAsync = r.id != null
        ? ref.watch(cuisinesStreamProvider(r.id!))
        : AsyncValue.data(r.categories.expand((c) => c.items).toList());

    final isFav = ref.watch(isFavouriteProvider(r.id));

    final menu = menuAsync.maybeWhen(
      data: (items) => items.where((item) {
        if (_searchQuery.isEmpty) return true;
        return item.name.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery);
      }).toList(),
      orElse: () => r.categories.expand((c) => c.items).where((item) {
        if (_searchQuery.isEmpty) return true;
        return item.name.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery);
      }).toList(),
    );

    final isWide = context.isWide;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
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
                l10n.itemsCount(ref.watch(cartTotalItemsProvider)),
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
                  child: CircleButton(
                    icon: isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: Colors.red,
                    onTap: () => unawaited(
                      ref.read(favouritesProvider.notifier).toggleFavourite(r),
                    ),
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
                    onTap: () => LauncherUtils.launchPhone('+9779800000000'),
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
                      child: AppImage(
                        imagePath: r.logoUrl ?? '',
                        width: MediaQuery.of(context).size.width,
                        height: isWide ? 400 : 320,
                        fit: BoxFit.cover,
                      ),
                    ),
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

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        MetaChip(
                          icon: Icons.location_on_rounded,
                          label: (r.locationAddress ?? 'Various')
                              .split(',')
                              .first,
                          color: colorScheme.primary,
                        ),
                        const MetaChip(
                          icon: Icons.access_time_filled_rounded,
                          label: '30 min',
                          color: Colors.orange,
                        ),
                        if (r.minOrderAmount > 0)
                          MetaChip(
                            icon: Icons.payments_rounded,
                            label:
                                '${l10n.minOrder} Rs. ${r.minOrderAmount.toStringAsFixed(0)}',
                            color: Colors.green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),

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

                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    Text(
                      l10n.menu,
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
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : const Color(0xFFF3F4F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: l10n.searchMenu,
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
                                      child: MenuItemCard(
                                        item: menu[index],
                                        restaurantId: r.id,
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
                                      child: MenuItemCard(
                                        item: menu[index],
                                        restaurantId: r.id,
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
                          l10n.reviews,
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
                            l10n.writeAReview,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', '5.0', '4.0', '3.0', '2.0'].map((
                          filter,
                        ) {
                          final isSelected = _selectedReviewFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                filter == 'All' ? 'All Reviews' : '$filter ★',
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
                        return ReviewCard(
                          index: index,
                          name: review.name,
                          rating: review.rating,
                          time: review.time,
                          comment: review.comment,
                          images: review.images,
                          onEdit: () => _showWriteReviewSheet(
                            context,
                            editReview: review,
                            index: _reviews.indexOf(review),
                          ),
                          onDelete: () {
                            setState(() {
                              _reviews.remove(review);
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
                        return ReviewCard(
                          index: index,
                          name: review.name,
                          rating: review.rating,
                          time: review.time,
                          comment: review.comment,
                          images: review.images,
                          onEdit: () => _showWriteReviewSheet(
                            context,
                            editReview: review,
                            index: _reviews.indexOf(review),
                          ),
                          onDelete: () {
                            setState(() {
                              _reviews.remove(review);
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
  }
}
