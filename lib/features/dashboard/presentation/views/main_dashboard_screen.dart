import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cart/presentation/views/cart_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/views/profile_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_skeletons.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_slivers.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/orders/presentation/views/orders_screen.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';

class MainDashBoard extends ConsumerStatefulWidget {
  final UserModel? user;
  final int initialIndex;
  const MainDashBoard({super.key, this.user, this.initialIndex = 0});

  @override
  ConsumerState<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends ConsumerState<MainDashBoard> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 400 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
    final allCuisinesAsync = ref.watch(allCuisinesStreamProvider);

    final screens = [
      _buildHomeView(context, colorScheme, restaurantsAsync, allCuisinesAsync),
      const CartScreen(),
      const OrdersScreen(),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildFloatingBottomNav(colorScheme),
      floatingActionButton: _currentIndex == 0 && _showBackToTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  unawaited(
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            )
          : null,
    );
  }

  Widget _buildFloatingBottomNav(ColorScheme colorScheme) {
    final cartItems = ref.watch(cartProvider).value ?? [];
    final activeOrders = ref
        .watch(ordersProvider)
        .where(
          (o) =>
              o.subStatus != OrderSubStatus.success &&
              o.subStatus != OrderSubStatus.cancelled,
        )
        .toList();

    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge.count(
                count: cartItems.length,
                isLabelVisible: cartItems.isNotEmpty,
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Badge.count(
                count: activeOrders.length,
                isLabelVisible: activeOrders.isNotEmpty,
                child: const Icon(Icons.receipt_long_rounded),
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(colorScheme),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(ColorScheme colorScheme) {
    final user = widget.user;
    final hasImage = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;
    final isSelected = _currentIndex == 3;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: hasImage ? NetworkImage(user.avatarUrl!) : null,
        child: !hasImage
            ? Text(
                user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildHomeView(
    BuildContext context,
    ColorScheme colorScheme,
    AsyncValue<List<RestaurantModel>> restaurantsAsync,
    AsyncValue<List<MenuItemModel>> allCuisinesAsync,
  ) {
    final restaurants = restaurantsAsync.value ?? <RestaurantModel>[];
    final allCuisines = allCuisinesAsync.value ?? <MenuItemModel>[];
    final offers = allCuisines.where((c) => c.price < 500).take(5).toList();
    final recommended = restaurants
        .where((r) => r.rating >= 4.5)
        .take(4)
        .toList();

    return ResponsiveCenter(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            toolbarHeight: 0, // Hidden app bar to use custom location/search
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Current Location',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          Text(
                            'Kathmandu, Nepal',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        onPressed: () =>
                            GoRouter.of(context).pushNamed('searchScreen'),
                        icon: const Icon(Icons.search_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (restaurantsAsync.isLoading && !restaurantsAsync.hasValue)
            const SliverFillRemaining(child: DashboardSkeleton())
          else
            DashboardSlivers(
              restaurants: restaurants,
              recommendedRestaurants: recommended,
              cuisines: allCuisines,
              offers: offers,
              countries: const [], // Countries removed as per request
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Space for floating nav
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed('searchScreen'),
              child: const AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food, restaurants...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class DashboardSlivers extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final List<RestaurantModel> recommendedRestaurants;
  final List<MenuItemModel> cuisines;
  final List<MenuItemModel> offers;
  final List<dynamic> countries; // Kept for compatibility but unused

  const DashboardSlivers({
    required this.restaurants,
    required this.recommendedRestaurants,
    required this.cuisines,
    required this.offers,
    required this.countries,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty && cuisines.isEmpty && offers.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        if (recommendedRestaurants.isNotEmpty)
          SliverRestaurantCards(
            headingTitle: 'Recommended Restaurants',
            items: recommendedRestaurants,
            seeAll: true,
          ),
        if (offers.isNotEmpty)
          SliverOfferCards(
            headingTitle: 'Hot Deals',
            items: offers,
            seeAll: true,
          ),
        if (cuisines.isNotEmpty)
          SliverFoodCards(
            headingTitle: 'Best Pick Food Items',
            items: cuisines,
            seeAll: true,
          ),
        if (restaurants.isNotEmpty)
          SliverRestaurantCards(
            headingTitle: 'Popular Restaurants',
            items: restaurants,
            seeAll: true,
          ),
      ],
    );
  }
}
