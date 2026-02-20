import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/restaurant_model.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:restro_hub/login/screens/restaurant_menu_screen.dart';

class ExploreRestaurantsScreen extends ConsumerStatefulWidget {
  const ExploreRestaurantsScreen({super.key});

  @override
  ConsumerState<ExploreRestaurantsScreen> createState() =>
      _ExploreRestaurantsScreenState();
}

class _ExploreRestaurantsScreenState
    extends ConsumerState<ExploreRestaurantsScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = [
    "All",
    "Top Rated",
    "Fast Delivery",
    "Cost Effective",
    "Premium",
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    List<Restaurant> filteredRestaurants = exploreRestaurants;
    if (_selectedFilter == "Top Rated") {
      filteredRestaurants = exploreRestaurants
          .where((r) => double.parse(r.rating) >= 4.7)
          .toList();
    } else if (_selectedFilter == "Fast Delivery") {
      filteredRestaurants = exploreRestaurants
          .where(
            (r) =>
                r.deliveryTime.contains("20") || r.deliveryTime.contains("25"),
          )
          .toList();
    } else if (_selectedFilter == "Cost Effective") {
      filteredRestaurants = exploreRestaurants
          .where((r) => r.priceRange.length <= 2)
          .toList();
    } else if (_selectedFilter == "Premium") {
      filteredRestaurants = exploreRestaurants
          .where((r) => r.priceRange.length >= 3)
          .toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Popular Restaurants",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primaryContainer, colorScheme.surface],
                  ),
                ),
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.restaurant,
                    size: 200,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => _selectedFilter = filter),
                      selectedColor: colorScheme.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final restaurant = filteredRestaurants[index];
                return _buildRestaurantCard(context, restaurant);
              }, childCount: filteredRestaurants.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    final colorScheme = context.colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantMenuScreen(restaurant: restaurant),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  restaurant.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        restaurant.priceRange,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoTile(
                        Icons.access_time_filled,
                        restaurant.deliveryTime,
                        colorScheme,
                      ),
                      const SizedBox(width: 24),
                      _buildInfoTile(
                        Icons.location_on,
                        restaurant.location.split(',').first,
                        colorScheme,
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

  Widget _buildInfoTile(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}
