import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cart/presentation/views/cart_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/views/profile_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_skeletons.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_slivers.dart';
import 'package:restro_hub/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/orders/presentation/views/orders_screen.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';

final dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class MainDashBoard extends ConsumerStatefulWidget {
  final UserModel? user;
  final int initialIndex;
  const MainDashBoard({super.key, this.user, this.initialIndex = 0});

  @override
  ConsumerState<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends ConsumerState<MainDashBoard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // Use a post-frame callback to update the provider after the first build
    // if it differs from the initialIndex
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(dashboardTabIndexProvider) != widget.initialIndex) {
        ref.read(dashboardTabIndexProvider.notifier).state =
            widget.initialIndex;
      }
    });
  }

  @override
  void didUpdateWidget(MainDashBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dashboardTabIndexProvider.notifier).state =
            widget.initialIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    ref.read(dashboardTabIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardTabIndexProvider);
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
      body: screens[currentIndex],
      bottomNavigationBar: _buildFloatingBottomNav(colorScheme, currentIndex),
    );
  }

  Widget _buildFloatingBottomNav(ColorScheme colorScheme, int currentIndex) {
    final cartItems = ref.watch(cartProvider).value ?? [];
    final activeOrders = (ref.watch(ordersProvider).value ?? [])
        .where(
          (o) =>
              o.subStatus != OrderSubStatus.success &&
              o.subStatus != OrderSubStatus.cancelled,
        )
        .toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Container(
          height: 80,
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
              currentIndex: currentIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
              selectedFontSize: 10,
              unselectedFontSize: 10,
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
                  icon: _buildProfileIcon(colorScheme, currentIndex),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(ColorScheme colorScheme, int currentIndex) {
    final user = widget.user;
    final hasImage = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;
    final isSelected = currentIndex == 3;

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
    const currentLocation = 'Kathmandu'; // Mock current location

    // Filter by location for categories
    final allRestaurants = (restaurantsAsync.value ?? <RestaurantModel>[])
        .where(
          (r) => r.locationAddress?.contains(currentLocation) ?? true,
        )
        .toList();

    final restaurants = allRestaurants.take(5).toList();

    final allCuisines = (allCuisinesAsync.value ?? <MenuItemModel>[]).where((
      c,
    ) {
      // If we want filtering by location for cuisines, we'd need to link back to restaurant.
      // For now, let's keep the baseline logic but filtered by the current restaurants.
      return true;
    }).toList();

    final cuisines = allCuisines.take(5).toList();

    final recommendedRestaurants =
        (restaurantsAsync.value ?? <RestaurantModel>[])
            .where((r) => r.rating >= 4.0)
            .take(5)
            .toList();

    final recommendedFood = allCuisines
        .where((f) => f.rating >= 4.5)
        .take(5)
        .toList();

    final recommendedItems = [...recommendedRestaurants, ...recommendedFood]
      ..sort((a, b) {
        final rA = a is RestaurantModel
            ? a.rating
            : (a as MenuItemModel).rating;
        final rB = b is RestaurantModel
            ? b.rating
            : (b as MenuItemModel).rating;
        return rB.compareTo(rA);
      });

    final unreadNotifications = ref
        .watch(notificationsProvider)
        .where((n) => !n.isRead)
        .length;

    final offers = allCuisines.where((c) => c.price < 500).take(5).toList();

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
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () {
                              final isDark =
                                  ref.read(themeProvider) == ThemeMode.dark;
                              ref
                                  .read(themeProvider.notifier)
                                  .toggleTheme(isDark: !isDark);
                            },
                            icon: Icon(
                              ref.watch(themeProvider) == ThemeMode.dark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () =>
                                context.pushNamed('notificationsScreen'),
                            icon: Badge.count(
                              count: unreadNotifications,
                              isLabelVisible: unreadNotifications > 0,
                              child: const Icon(Icons.notifications_rounded),
                            ),
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
                  const SizedBox(height: 16),
                  // Full Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              GoRouter.of(context).pushNamed('searchScreen'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(
                                    alpha: 0.5,
                                  ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search for food, restaurants...',
                                  style: GoogleFonts.poppins(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => context.push('/aiSearch'),
                        icon: const Icon(Icons.auto_awesome),
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
              recommendedItems: recommendedItems,
              cuisines: cuisines,
              offers: offers,
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Space for floating nav
        ],
      ),
    );
  }
}

class DashboardSlivers extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final List<dynamic> recommendedItems;
  final List<MenuItemModel> cuisines;
  final List<MenuItemModel> offers;

  const DashboardSlivers({
    required this.restaurants,
    required this.recommendedItems,
    required this.cuisines,
    required this.offers,
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
        if (recommendedItems.isNotEmpty)
          SliverRestaurantCards(
            headingTitle: 'Recommended',
            titleIcon: Icons.star_rounded,
            items: recommendedItems,
            seeAll: true,
            exploreType: ExploreType.recommended,
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
            titleIcon: Icons.restaurant_menu_rounded,
            items: cuisines,
            seeAll: true,
          ),
        if (restaurants.isNotEmpty)
          SliverRestaurantCards(
            headingTitle: 'Popular Restaurants',
            titleIcon: Icons.storefront_rounded,
            items: restaurants,
            seeAll: true,
          ),
      ],
    );
  }
}
