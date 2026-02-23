import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/cuisines/data/models/cuisine_model.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';

class AllCousineList extends ConsumerStatefulWidget {
  final String title;
  final List<CuisineModel> items;

  const AllCousineList({super.key, required this.title, required this.items});

  @override
  ConsumerState<AllCousineList> createState() => _AllCousineListState();
}

class _AllCousineListState extends ConsumerState<AllCousineList> {
  double _maxPrice = 3000.0;
  double _minRating = 0.0;
  String _selectedLocation = "All";

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final cart = ref.watch(cartProvider);
    final totalItems = cart.fold(0, (sum, item) => sum + (item.quantity));
    const bool enableFilters = false;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CartBottomSheet(),
                );
              },
              label: Text("$totalItems items"),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
      body: SearchableSliverAppLayout<CuisineModel>(
        title: "Cuisines",
        items: widget.items,
        hintText: "Search in Cuisines",
        enableFilters: enableFilters,
        filterPredicate: (item, query) {
          final matchesQuery =
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase());

          if (!enableFilters) return matchesQuery;

          // These other filters will only be "changeable" by the user if enableFilters is true
          final matchesPrice = item.price <= _maxPrice;
          final matchesRating = double.parse(item.rating) >= _minRating;
          final matchesLocation =
              _selectedLocation == "All" ||
              item.location.contains(_selectedLocation);

          return matchesQuery &&
              matchesPrice &&
              matchesRating &&
              matchesLocation;
        },
        customFilterBuilder: enableFilters
            ? (context, selected, onChanged) {
                final colorScheme = context.colorScheme;
                return Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPriceTag(colorScheme),
                            const SizedBox(width: 8),
                            _buildRatingTag(colorScheme),
                            const SizedBox(width: 8),
                            _buildLocationTag(colorScheme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterAction(colorScheme),
                  ],
                );
              }
            : null,
        itemBuilder: (context, item, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ExploreItemsList(item: item),
          );
        },
      ),
    );
  }

  Widget _buildPriceTag(ColorScheme colorScheme) {
    return _buildHeaderChip(
      icon: Icons.payments_outlined,
      label: "Rs. ${_maxPrice.toInt()}",
      onTap: _showFilterSheet,
      colorScheme: colorScheme,
    );
  }

  Widget _buildRatingTag(ColorScheme colorScheme) {
    return _buildHeaderChip(
      icon: Icons.star_outline,
      label: "${_minRating.toInt()}+",
      onTap: _showFilterSheet,
      colorScheme: colorScheme,
    );
  }

  Widget _buildLocationTag(ColorScheme colorScheme) {
    return _buildHeaderChip(
      icon: Icons.location_on_outlined,
      label: _selectedLocation,
      onTap: _showFilterSheet,
      colorScheme: colorScheme,
    );
  }

  Widget _buildFilterAction(ColorScheme colorScheme) {
    return IconButton.filledTonal(
      onPressed: _showFilterSheet,
      icon: const Icon(Icons.tune, size: 20),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final colorScheme = context.colorScheme;
    final locations = ["All", ...widget.items.map((e) => e.location).toSet()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _maxPrice = 3000.0;
                            _minRating = 0.0;
                            _selectedLocation = "All";
                          });
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Max Price",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Rs. ${_maxPrice.toInt()}"),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 0,
                    max: 3000,
                    divisions: 30,
                    label: "Rs. ${_maxPrice.toInt()}",
                    onChanged: (value) {
                      setModalState(() => _maxPrice = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Minimum Rating",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [0.0, 1.0, 2.0, 3.0, 4.0].map((r) {
                      final isSelected = _minRating == r;
                      return ChoiceChip(
                        label: Text("$r+"),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => _minRating = r);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: locations.map((loc) {
                      final isSelected = _selectedLocation == loc;
                      return ChoiceChip(
                        label: Text(loc),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => _selectedLocation = loc);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ExploreItemsList extends ConsumerWidget {
  final CuisineModel item;
  const ExploreItemsList({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final isFav = ref.watch(favouritesProvider.notifier).isFavourite(item);
    ref.watch(favouritesProvider);

    return GestureDetector(
      onTap: () {
        context.pushNamed("cuisineSingleItem", extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 35,
              offset: const Offset(0, 15),
              spreadRadius: -8,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'item_${item.name}_${item.image}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      item.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) return child;
                            return frame != null
                                ? child
                                : const ShimmerPlaceholder(
                                    width: double.infinity,
                                    height: 180,
                                  );
                          },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        ref
                            .read(favouritesProvider.notifier)
                            .toggleFavourite(item);
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.location,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            item.rating,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${item.price}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (item.offerPercent.isNotEmpty &&
                          item.offerPercent != "0%")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${item.offerPercent} OFF",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
}
