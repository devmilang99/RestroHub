import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredMenu {
    if (_searchQuery.isEmpty) return widget.restaurant.menu;
    return widget.restaurant.menu
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery) ||
              item.description.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.restaurant;
    final menu = _filteredMenu;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF7F8FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero image app bar ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _CircleBtn(
                  icon: Icons.favorite_border_rounded,
                  iconColor: Colors.red,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: _CircleBtn(icon: Icons.share_rounded, onTap: () {}),
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
                    tag: "restaurant_${r.name}",
                    child: Image.asset(r.image, fit: BoxFit.cover),
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
                color: isDark ? colorScheme.surface : Colors.white,
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
                              r.rating,
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
                        label: r.location.split(',').first,
                        color: colorScheme.primary,
                      ),
                      _MetaChip(
                        icon: Icons.access_time_filled_rounded,
                        label: r.deliveryTime,
                        color: Colors.orange,
                      ),
                      _MetaChip(
                        icon: Icons.currency_rupee_rounded,
                        label: r.priceRange,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // description
                  Text(
                    r.description,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface.withValues(alpha: 0.58),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Menu Search ──
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    "Menu",
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
                        hintText: "Search in menu…",
                        hintStyle: GoogleFonts.poppins(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
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
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No items found",
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

          // ── Menu items list ────────────────────────────────────────────
          if (menu.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _MenuItemCard(
                    item: menu[index],
                    index: index,
                    isFirst: index == 0,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),
                  childCount: menu.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Menu item card with staggered entrance animation ─────────────────────────
class _MenuItemCard extends StatefulWidget {
  final dynamic item;
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
  State<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<_MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
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
    final item = widget.item;
    final isDark = widget.isDark;
    final cs = widget.colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => context.pushNamed("cuisineSingleItem", extra: item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: isDark ? 0.12 : 0.4),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // thumbnail
                Hero(
                  tag: "res_${item.name}",
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Image.asset(
                      item.image,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // badge (signature for first item)
                        if (widget.isFirst)
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
                              "SIGNATURE",
                              style: GoogleFonts.poppins(
                                color: Colors.deepOrange,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
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
                              "Rs. ${item.price}",
                              style: GoogleFonts.poppins(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 17,
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

// ── Circular icon button (frosted feel) ───────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 17, color: iconColor ?? Colors.black87),
      ),
    );
  }
}
