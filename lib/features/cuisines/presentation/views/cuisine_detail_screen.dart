import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/circle_button.dart';
import 'package:restro_hub/core/widgets/share_bottom_sheet.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';

class CuisineSingleItem extends ConsumerWidget {
  final MenuItemModel item;
  const CuisineSingleItem({required this.item, super.key});

  void _showAddedNotification(BuildContext context, String itemName) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 100),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Added to Cart!',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$itemName has been added.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            entry.remove();
                            unawaited(
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const CartBottomSheet(),
                              ),
                            );
                          },
                          child: const Text(
                            'VIEW',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
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
    );

    overlay.insert(entry);
    unawaited(
      Future.delayed(const Duration(seconds: 3), () {
        if (entry.mounted) entry.remove();
      }),
    );
  }

  void _openImageSlider(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        useSafeArea: false,
        builder: (context) =>
            _ImageSliderDialog(images: images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isFav = ref.watch(favouritesProvider.notifier).isFavourite(item);
    ref.watch(favouritesProvider);

    // Mock data if missing
    final ingredients = [
      'Fresh Herbs',
      'Signature Spices',
      'Local Produce',
      'Organic Olive Oil',
      'Sea Salt',
    ];

    final comments = [
      "This is absolutely the best version of this dish I've ever had! The balance of flavors is perfection.",
      'Great portion size and it arrived surprisingly fast. Will definitely order again next time.',
      'Simply incredible! You can tell they use authentic ingredients. High quality through and through.',
    ];

    final mockReviewImages = [
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1473093226795-af9932fe5856?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1493770348161-369560ae357d?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=400&auto=format&fit=crop',
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            centerTitle: true,
            title: LayoutBuilder(
              builder: (context, constraints) {
                final opacity =
                    (constraints.maxHeight - kToolbarHeight) /
                    (350 - kToolbarHeight);
                return Opacity(
                  opacity: (1.0 - opacity).clamp(0.0, 1.0),
                  child: Text(
                    item.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircleButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: Colors.red,
                      onTap: () {
                        unawaited(
                          ref
                              .read(favouritesProvider.notifier)
                              .toggleFavourite(item),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    CircleButton(
                      icon: Icons.share_rounded,
                      onTap: () {
                        ShareBottomSheet.show(
                          context,
                          title: item.name,
                          shareLink:
                              "restrohub://cuisine/${item.name.toLowerCase().replaceAll(' ', '_')}",
                        );
                      },
                    ),
                  ],
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
                    tag: item.name,
                    child: (item.imageUrl?.startsWith('assets') ?? false)
                        ? Image.asset(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: item.imageUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 350,
                                ),
                          ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.5', // Default rating
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Various', // Location not in MenuItemModel
                          style: TextStyle(
                            color: Color(
                              0xFF6B7280,
                            ), // dummy colorScheme.onSurfaceVariant
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.public, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Global', // country not in MenuItemModel
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    item.description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    'Ingredients',
                    Icons.restaurant_menu_rounded,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ingredients
                        .map(
                          (ingredient) =>
                              _buildIngredientChip(context, ingredient),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    'Reviews',
                    Icons.reviews_rounded,
                  ),
                  const SizedBox(height: 16),
                  ...comments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final comment = entry.value;
                    return _buildReviewCard(
                      context,
                      index,
                      comment,
                      index.isEven ? mockReviewImages : [],
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Rs. ${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(cartProvider.notifier)
                      .addItem(
                        CartModel(
                          id: item.id,
                          name: item.name,
                          image: item.imageUrl ?? '',
                          price: item.price,
                          quantity: 1,
                        ),
                      );
                  context.push('/processCheckout');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Order',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .addItem(
                      CartModel(
                        id: item.id,
                        name: item.name,
                        image: item.imageUrl ?? '',
                        price: item.price,
                        quantity: 1,
                      ),
                    );
                _showAddedNotification(context, item.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Icon(Icons.add_shopping_cart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 22, color: context.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(BuildContext context, String ingredient) {
    final colorScheme = context.colorScheme;

    IconData getIcon(String name) {
      final lowercaseName = name.toLowerCase();
      if (lowercaseName.contains('rice')) return Icons.rice_bowl;
      if (lowercaseName.contains('spices')) return Icons.set_meal;
      if (lowercaseName.contains('oil')) return Icons.opacity;
      if (lowercaseName.contains('vegetable') ||
          lowercaseName.contains('herbs')) {
        return Icons.park_rounded;
      }
      if (lowercaseName.contains('chicken') ||
          lowercaseName.contains('meat') ||
          lowercaseName.contains('beef')) {
        return Icons.restaurant;
      }
      if (lowercaseName.contains('garlic') || lowercaseName.contains('onion')) {
        return Icons.bubble_chart;
      }
      if (lowercaseName.contains('cheese') ||
          lowercaseName.contains('parmesan')) {
        return Icons.bakery_dining;
      }
      return Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getIcon(ingredient), size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            ingredient,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    int index,
    String comment,
    List<String> images,
  ) {
    final colorScheme = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=$index',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ['Alex Rivera', 'Mia Thompson', 'James Wilson'][index %
                          3],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '2 days ago',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < 4 ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
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
