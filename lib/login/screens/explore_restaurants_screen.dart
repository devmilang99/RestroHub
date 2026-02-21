import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/restaurant_model.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:restro_hub/login/screens/restaurant_menu_screen.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';

class ExploreRestaurantsScreen extends ConsumerStatefulWidget {
  const ExploreRestaurantsScreen({super.key});

  @override
  ConsumerState<ExploreRestaurantsScreen> createState() =>
      _ExploreRestaurantsScreenState();
}

class _ExploreRestaurantsScreenState
    extends ConsumerState<ExploreRestaurantsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = "All";
  late AnimationController _bgAnimController;

  final List<String> _filters = [
    "All",
    "Top Rated",
    "Fast Delivery",
    "Cost Effective",
    "Premium",
  ];

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  List<Restaurant> get _filteredRestaurants {
    var list = exploreRestaurants;
    if (_selectedFilter == "Top Rated") {
      list = list.where((r) => double.parse(r.rating) >= 4.7).toList();
    } else if (_selectedFilter == "Fast Delivery") {
      list = list
          .where(
            (r) =>
                r.deliveryTime.contains("20") || r.deliveryTime.contains("25"),
          )
          .toList();
    } else if (_selectedFilter == "Cost Effective") {
      list = list.where((r) => r.priceRange.length <= 2).toList();
    } else if (_selectedFilter == "Premium") {
      list = list.where((r) => r.priceRange.length >= 3).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredRestaurants;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // ── Animated mesh gradient background (light mode only) ──
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

          // ── Reusable Searchable Layout ──
          SearchableSliverAppLayout<Restaurant>(
            items: filtered,
            title: "Restaurants",
            hintText: "Search restaurants or cuisines…",
            expandedHeight: 240,
            showBackButton: true,
            onBackPressed: () => context.pop(),
            filterPredicate: (r, query) =>
                r.name.toLowerCase().contains(query.toLowerCase()) ||
                r.description.toLowerCase().contains(query.toLowerCase()),
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
                      'Find Your Favorite',
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
            filterBar: _buildFilterChips(colorScheme, isDark),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemBuilder: (context, restaurant, index) =>
                _RestaurantCard(restaurant: restaurant, index: index),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme, bool isDark) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final f = _filters[i];
          final active = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: active,
              onSelected: (_) => setState(() => _selectedFilter = f),
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

// ── Restaurant Card ─────────────────────────────────────────────────────────
class _RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final int index;
  const _RestaurantCard({required this.restaurant, required this.index});

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.restaurant;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantMenuScreen(restaurant: r),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDark
                  ? null
                  : [
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
                // ── Image ──
                Stack(
                  children: [
                    Image.asset(
                      r.image,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                              r.rating,
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

                // ── Info ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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
                          _Chip(
                            icon: Icons.access_time_filled_rounded,
                            label: r.deliveryTime,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          _Chip(
                            icon: Icons.location_on_rounded,
                            label: r.location.split(',').first,
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

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

// ── Animated mesh gradient painter ───────────────────────────────────────────
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
        Colors.purple.withValues(alpha: 0.04),
      ),
      _Spot(
        Offset(
          size.width * (0.5 + 0.05 * math.sin(progress * math.pi * 2 + 1)),
          size.height * 0.5,
        ),
        size.width * 0.55,
        Colors.orange.withValues(alpha: 0.035),
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
