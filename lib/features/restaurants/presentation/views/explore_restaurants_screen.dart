import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_skeletons.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

class ExploreRestaurantsScreen extends ConsumerStatefulWidget {
  const ExploreRestaurantsScreen({super.key});

  @override
  ConsumerState<ExploreRestaurantsScreen> createState() =>
      _ExploreRestaurantsScreenState();
}

class _ExploreRestaurantsScreenState
    extends ConsumerState<ExploreRestaurantsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    unawaited(_bgAnimController.repeat(reverse: true));
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final filtered = ref.watch(filteredRestaurantsProvider);
    final selectedFilter = ref.watch(restaurantFilterProvider);
    final notifier = ref.read(filteredRestaurantsProvider.notifier);

    final filters = [
      l10n.all,
      l10n.topRated,
      l10n.fastDelivery,
      l10n.costEffective,
      l10n.premium,
    ];

    final filterMap = {
      l10n.all: 'All',
      l10n.topRated: 'Top Rated',
      l10n.fastDelivery: 'Fast Delivery',
      l10n.costEffective: 'Cost Effective',
      l10n.premium: 'Premium',
    };

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF7F8FC),
      body: ResponsiveCenter(
        child: Stack(
          children: [
            if (!isDark)
              AnimatedBuilder(
                animation: _bgAnimController,
                builder: (_, child) => CustomPaint(
                  painter: _MeshGradientPainter(
                    progress: _bgAnimController.value,
                    primary: colorScheme.primary,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            SearchableSliverAppLayout<RestaurantModel>(
              items: filtered.value ?? [],
              isLoading: filtered.isLoading && !filtered.hasValue,
              skeleton: const SliverGridSkeleton(
                itemCount: 6,
                childAspectRatio: 0.75,
              ),
              title: l10n.restaurants,
              hintText: l10n.searchHint,
              onBackPressed: () => context.pop(),
              onLoadMore: notifier.loadMore,
              isLoadingMore: filtered.isLoading && filtered.hasValue,
              isGrid: context.isWide,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.isDesktop ? 3 : 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              onSearchChanged: (query) {
                ref.read(restaurantSearchProvider.notifier).setSearch(query);
              },
              filterPredicate: (r, query) {
                return true;
              },
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.08),
                      colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 56,
                        color: colorScheme.primary.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.findYourFavorite,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              filterBar: _buildFilterChips(
                colorScheme,
                isDark,
                filters,
                selectedFilter,
                filterMap,
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemBuilder: (context, restaurant, index) =>
                  AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: context.isDesktop ? 3 : 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _RestaurantCard(
                          restaurant: restaurant,
                          index: index,
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    ColorScheme colorScheme,
    bool isDark,
    List<String> filters,
    String selectedFilter,
    Map<String, String> filterMap,
  ) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final f = filters[i];
          final logicalFilter = filterMap[f] ?? 'All';
          final active = selectedFilter == logicalFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f,
                style: const TextStyle(fontSize: 10), // Smaller font to fit
              ),
              selected: active,
              onSelected: (_) =>
                  ref.read(restaurantFilterProvider.notifier).filter =
                      logicalFilter,
              selectedColor: colorScheme.primary,
              backgroundColor: isDark ? Colors.white10 : Colors.white,
              showCheckmark: false,
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : colorScheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: active
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantCard extends StatefulWidget {
  final RestaurantModel restaurant;
  final int index;
  const _RestaurantCard({required this.restaurant, required this.index});

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    unawaited(_ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.restaurant;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => RestaurantMenuScreen(restaurant: r),
            ),
          ),
          child: Container(
            margin: context.isWide
                ? EdgeInsets.zero
                : const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'restaurant_${r.name}',
                        child: (r.logoUrl?.startsWith('assets') ?? false)
                            ? Image.asset(r.logoUrl!, fit: BoxFit.cover)
                            : CachedNetworkImage(
                                imageUrl: r.logoUrl ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                r.rating.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            r.priceRange,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const _Chip(
                            icon: Icons.access_time_filled_rounded,
                            label: '30 min',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          _Chip(
                            icon: Icons.location_on_rounded,
                            label: (r.locationAddress ?? 'Various')
                                .split(',')
                                .first,
                            color: colorScheme.primary,
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
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
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

class _MeshGradientPainter extends CustomPainter {
  final double progress;
  final Color primary;
  _MeshGradientPainter({required this.progress, required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final spots = [
      _Spot(
        Offset(
          size.width * (0.1 + 0.1 * math.sin(progress * math.pi * 2)),
          size.height * 0.1,
        ),
        size.width * 0.5,
        primary.withValues(alpha: 0.06),
      ),
      _Spot(
        Offset(
          size.width * 0.8,
          size.height * (0.05 + 0.05 * math.cos(progress * math.pi * 2)),
        ),
        size.width * 0.45,
        primary.withValues(alpha: 0.04),
      ),
      _Spot(
        Offset(
          size.width * (0.5 + 0.05 * math.sin(progress * math.pi * 2 + 1)),
          size.height * 0.5,
        ),
        size.width * 0.55,
        primary.withValues(alpha: 0.035),
      ),
    ];

    for (final spot in spots) {
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [spot.color, spot.color.withValues(alpha: 0)],
            ).createShader(
              Rect.fromCircle(center: spot.center, radius: spot.radius),
            );
      canvas.drawCircle(spot.center, spot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter old) =>
      old.progress != progress || old.primary != primary;
}

class _Spot {
  final Offset center;
  final double radius;
  final Color color;
  const _Spot(this.center, this.radius, this.color);
}
