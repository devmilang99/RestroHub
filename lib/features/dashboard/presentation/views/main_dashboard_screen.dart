import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/responsive_center.dart';
import 'package:restro_hub/core/widgets/sync_progress_overlay.dart';
import 'package:restro_hub/features/ai/presentation/ai_search_notifier.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/cart/presentation/views/cart_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/providers/cuisine_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:restro_hub/features/dashboard/presentation/views/profile_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_skeletons.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_slivers.dart';
import 'package:restro_hub/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/orders/presentation/views/orders_screen.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';

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

    final screens = [
      _buildHomeView(context, colorScheme),
      const CartScreen(),
      const OrdersScreen(),
      ProfileScreen(user: widget.user),
    ];

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: _buildFloatingBottomNav(
            colorScheme,
            currentIndex,
          ),
        ),
        const SyncProgressOverlay(),
      ],
    );
  }

  Widget _buildFloatingBottomNav(ColorScheme colorScheme, int currentIndex) {
    final cartItems = ref.watch(cartProvider).value ?? [];
    final activeOrders = (ref.watch(ordersProvider).value ?? [])
        .where(
          (o) =>
              o.subStatus != OrderSubStatus.completed &&
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

  Widget _buildHomeView(BuildContext context, ColorScheme colorScheme) {
    final unreadNotifications = ref
        .watch(notificationsProvider)
        .where((n) => !n.isRead)
        .length;

    final restaurantsAsync = ref.watch(dashboardPopularRestaurantsProvider);
    final recommendedItemsAsync = ref.watch(dashboardRecommendedItemsProvider);
    final cuisinesAsync = ref.watch(dashboardBestPickFoodProvider);
    final offersAsync = ref.watch(dashboardOffersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(supabaseSyncManagerProvider.notifier)
            .syncRestaurants(force: true);
        // Also invalidate providers to ensure UI updates immediately
        ref.invalidate(dashboardPopularRestaurantsProvider);
        ref.invalidate(dashboardRecommendedItemsProvider);
        ref.invalidate(dashboardBestPickFoodProvider);
        ref.invalidate(dashboardOffersProvider);
      },
      child: ResponsiveCenter(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                                final isCurrentlyDark =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                ref
                                    .read(themeProvider.notifier)
                                    .toggleTheme(isDark: !isCurrentlyDark);
                              },
                              icon: Icon(
                                Theme.of(context).brightness == Brightness.dark
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
                                    'Search for foods...',
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
                          onPressed: () {
                            final aiState = ref.read(aiSearchProvider).value;
                            if (aiState != null && aiState.searchCount >= 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Hourly limit reached (5 searches). AI will be available again soon.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                              return;
                            }
                            context.push('/aiSearch');
                          },
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
            DashboardSlivers(
              restaurantsAsync: restaurantsAsync,
              recommendedItemsAsync: recommendedItemsAsync,
              cuisinesAsync: cuisinesAsync,
              offersAsync: offersAsync,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class DashboardSlivers extends StatelessWidget {
  final AsyncValue<List<RestaurantModel>> restaurantsAsync;
  final AsyncValue<List<dynamic>> recommendedItemsAsync;
  final AsyncValue<List<MenuItemModel>> cuisinesAsync;
  final AsyncValue<List<MenuItemModel>> offersAsync;

  const DashboardSlivers({
    required this.restaurantsAsync,
    required this.recommendedItemsAsync,
    required this.cuisinesAsync,
    required this.offersAsync,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        recommendedItemsAsync.when(
          data: (items) => items.isNotEmpty
              ? SliverRestaurantCards(
                  headingTitle: 'Recommended',
                  titleIcon: Icons.star_rounded,
                  items: items,
                  seeAll: true,
                  exploreType: ExploreType.recommended,
                )
              : const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverRestaurantCardsSkeleton(),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        restaurantsAsync.when(
          data: (items) => items.isNotEmpty
              ? SliverPopularCategories(
                  headingTitle: 'Popular Restaurants',
                  items: items,
                  seeAll: true,
                  titleIcon: Icons.auto_graph_rounded,
                )
              : const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverCountryCardsSkeleton(),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        offersAsync.when(
          data: (items) => items.isNotEmpty
              ? SliverOfferCards(
                  headingTitle: 'Hot Deals',
                  items: items,
                  seeAll: true,
                )
              : const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverOfferCardsSkeleton(),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        cuisinesAsync.when(
          data: (items) => items.isNotEmpty
              ? SliverFoodCards(
                  headingTitle: 'Best Pick Food Items',
                  titleIcon: Icons.restaurant_menu_rounded,
                  items: items,
                  seeAll: true,
                )
              : const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverFoodCardsSkeleton(),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}
