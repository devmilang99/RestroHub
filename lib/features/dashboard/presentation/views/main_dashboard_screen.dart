import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/orders/presentation/views/orders_screen.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/cuisines/data/models/cuisine_model.dart';
import 'package:restro_hub/features/country/data/models/country_model.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:restro_hub/features/dashboard/presentation/providers/loyalty_provider.dart';
import 'package:restro_hub/features/dashboard/logic/membership_rules.dart';
import 'dart:math' as math;

class MainDashBoard extends ConsumerStatefulWidget {
  final UserModel? user;
  const MainDashBoard({super.key, this.user});

  @override
  ConsumerState<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends ConsumerState<MainDashBoard> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 400 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });

    // Simulate loading for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final colorScheme = context.colorScheme;
    final cart = ref.watch(cartProvider);
    final totalItems = cart.fold(0, (sum, item) => sum + (item.quantity));

    final orders = ref.watch(ordersProvider);
    final activeOrdersCount = orders
        .where(
          (o) =>
              o.subStatus != OrderSubStatus.success &&
              o.subStatus != OrderSubStatus.cancelled,
        )
        .length;

    final List<Widget> pages = [
      _buildHomeView(context, colorScheme),
      const SizedBox.shrink(), // Placeholder for Cart (handled via bottom sheet)
      const OrdersScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          final shouldLogout = await showGeneralDialog<bool>(
            context: context,
            barrierDismissible: true,
            barrierLabel: '',
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: anim1.value,
                child: Opacity(
                  opacity: anim1.value,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: context.colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Exit Restro Hub',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to log out and exit the app?',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.error,
                          foregroundColor: context.colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'LOG OUT',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          if (shouldLogout == true && context.mounted) {
            context.goNamed('mainLoginScreen');
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        floatingActionButton: _currentIndex == 0 && _showBackToTop
            ? FloatingActionButton(
                mini: true,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : null,
        drawer: Drawer(
          child: Column(
            children: [
              _PremiumDrawerHeader(user: widget.user),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password'),
                      onTap: () {
                        context.pushNamed('authenticatedPasswordScreen');
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode'),
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme(value);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contact_support_outlined),
                      title: const Text('Contact Us'),
                      onTap: () {
                        context.pushNamed('contactUsScreen');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () {
                        context.goNamed('mainLoginScreen');
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Restro Hub v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(totalItems.toString()),
                isLabelVisible: totalItems > 0,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(activeOrdersCount.toString()),
                isLabelVisible: activeOrdersCount > 0,
                child: const Icon(Icons.food_bank_rounded),
              ),
              label: 'Orders',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CartBottomSheet(),
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildHomeView(BuildContext context, ColorScheme colorScheme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false, // The app bar hides when scrolling
          backgroundColor: colorScheme.surface,
          expandedHeight: 40,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, color: colorScheme.onSurface),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: GestureDetector(
            onTap: () async {
              final newLocation = await context.pushNamed('locationPicker');
              if (newLocation != null && context.mounted) {
                // In a real app, update location provider
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location updated to $newLocation')),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delivering to",
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Narayan Chowk",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),

          centerTitle: true,
          actions: [
            IconButton(
              icon: Badge(
                label: Text(
                  ref
                      .watch(notificationsProvider)
                      .where((n) => !n.isRead)
                      .length
                      .toString(),
                ),
                isLabelVisible: ref.watch(notificationsProvider).isNotEmpty,
                child: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface,
                ),
              ),
              onPressed: () => context.pushNamed('notificationsScreen'),
            ),
            IconButton(
              icon: Badge(
                label: Text(ref.watch(favouritesProvider).length.toString()),
                isLabelVisible: ref.watch(favouritesProvider).isNotEmpty,
                child: Icon(Icons.favorite, color: colorScheme.onSurface),
              ),
              onPressed: () {
                context.pushNamed("showFavourites");
              },
            ),
          ],
        ),

        // Countries Horizontal List
        _isLoading
            ? _SliverCountryCardsSkeleton()
            : SliverCountryCards(
                headingTitle: 'Explore by Cuisine',
                items: countries,
                displayCount: 6,
                seeAll: true,
              ),

        // Latest Offers
        _isLoading
            ? _SliverOfferCardsSkeleton()
            : SliverOfferCards(
                headingTitle: 'Latest Offers',
                items: latestOffers,
                displayCount: 5,
                seeAll: true,
              ),

        // Explore by Restaurant
        _isLoading
            ? _SliverRestaurantCardsSkeleton()
            : SliverRestaurantCards(
                headingTitle: 'Explore by Restaurant',
                items: restaurantsList,
                displayCount: 5,
                seeAll: true,
              ),

        // Top Rated
        _isLoading
            ? _SliverTopRatedCardsSkeleton()
            : SliverTopRatedCards(
                headingTitle: 'Top Rated',
                items: cuisines,
                displayCount: 5,
                seeAll: false,
              ),
      ],
    );
  }
}

class SliverVerticalCards extends StatelessWidget {
  final String headingTitle;
  final bool hasOffer;
  final bool isHorizontal;
  final bool isCircular;
  final String offerPercent;
  final String rating;
  final bool seeAll;
  final List<CuisineModel> items;
  final int? displayCount;

  const SliverVerticalCards({
    super.key,
    required this.headingTitle,
    this.hasOffer = false,
    this.isHorizontal = true,
    this.isCircular = false,
    this.offerPercent = "",
    this.rating = "",
    this.seeAll = false,
    required this.items,
    this.displayCount,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: seeAll,
                    child: TextButton(
                      key: Key(headingTitle),
                      onPressed: () {
                        if (headingTitle.contains('Cuisine')) {
                          context.pushNamed('exploreScreen');
                        } else if (headingTitle.contains('Restaurant')) {
                          context.pushNamed('exploreRestaurantsScreen');
                        } else {
                          context.pushNamed(
                            "allCouisineList",
                            extra: {'title': headingTitle, 'items': items},
                          );
                        }
                      },

                      child: const Text("See All"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isHorizontal && isCircular)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    return CircularRestaurantCard(
                      onClick: () {
                        context.pushNamed(
                          "cuisineSingleItem",
                          extra: displayItems[index],
                        );
                      },
                      name: displayItems[index].name,
                      index: index,
                      radius: 40,
                    );
                  },
                ),
              ),
            )
          else if (isHorizontal && !isCircular)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    return RestaurantCard(
                      onClick: () {
                        context.pushNamed(
                          "cuisineSingleItem",
                          extra: displayItems[index],
                        );
                      },
                      name: displayItems[index].name,
                      index: index,
                      hasOffer: hasOffer,
                      offerPercent: displayItems[index].offerPercent.isNotEmpty
                          ? displayItems[index].offerPercent
                          : offerPercent,
                      rating: displayItems[index].rating.isNotEmpty
                          ? displayItems[index].rating
                          : rating,
                      width: 200,
                      image: displayItems[index].image,
                    );
                  },
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return RestaurantCard(
                  onClick: () {
                    context.pushNamed(
                      "cuisineSingleItem",
                      extra: displayItems[index],
                    );
                  },
                  name: displayItems[index].name,
                  index: index,
                  hasOffer: hasOffer,
                  offerPercent: displayItems[index].offerPercent.isNotEmpty
                      ? displayItems[index].offerPercent
                      : offerPercent,
                  rating: displayItems[index].rating.isNotEmpty
                      ? displayItems[index].rating
                      : rating,
                  width: double.infinity,
                  image: displayItems[index].image,
                );
              }, childCount: displayItems.length),
            ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final int index;
  final bool hasOffer;
  final String offerPercent;
  final String rating;
  final double width;
  final Function onClick;
  final String image;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.index,
    this.hasOffer = false,
    this.offerPercent = "",
    this.rating = "",
    required this.width,
    required this.onClick,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {
          onClick();
        },
        child: Container(
          margin: const EdgeInsets.only(right: 16, bottom: 25),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -10,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 800, // Downscale for performance
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return frame != null
                      ? child
                      : const ShimmerPlaceholder(
                          width: double.infinity,
                          height: 160,
                          borderRadius: 0,
                        );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (hasOffer && offerPercent.isNotEmpty)
                          Text(
                            'Flat $offerPercent OFF',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '$rating ★',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverCountryCards extends StatelessWidget {
  final String headingTitle;
  final List<CountryModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverCountryCards({
    super.key,
    required this.headingTitle,
    required this.items,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () => context.pushNamed('countryListScreen'),
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Horizontal image cards ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final country = displayItems[index];
                  final cuisineCount = cuisines
                      .where((c) => c.country == country.name)
                      .length;

                  return GestureDetector(
                    onTap: () =>
                        context.pushNamed('exploreScreen', extra: country.name),
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Image.network(
                            country.historicalImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.primaryContainer,
                              child: Center(
                                child: Text(
                                  country.flag,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                          ),
                          // Gradient overlay
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.78),
                                ],
                                stops: const [0.35, 1.0],
                              ),
                            ),
                          ),
                          // Flag bubble top-left
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                country.flag,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          // Text bottom
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  country.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$cuisineCount+ dishes',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverOfferCards extends StatelessWidget {
  final String headingTitle;
  final List<CuisineModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverOfferCards({
    super.key,
    required this.headingTitle,
    required this.items,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Visibility(
                    visible: seeAll,
                    child: TextButton(
                      onPressed: () => context.pushNamed(
                        "allCouisineList",
                        extra: {'title': headingTitle, 'items': items},
                      ),
                      child: Text(
                        "View Deals",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return GestureDetector(
                    onTap: () =>
                        context.pushNamed("cuisineSingleItem", extra: item),
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Opacity(
                              opacity: 0.2,
                              child: Icon(
                                Icons.local_offer_rounded,
                                size: 150,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          "${item.offerPercent} OFF",
                                          style: GoogleFonts.poppins(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.name,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Limited time feast!",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      item.image,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverTopRatedCards extends StatefulWidget {
  final String headingTitle;
  final List<CuisineModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverTopRatedCards({
    super.key,
    required this.headingTitle,
    required this.items,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  State<SliverTopRatedCards> createState() => _SliverTopRatedCardsState();
}

class _SliverTopRatedCardsState extends State<SliverTopRatedCards>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 = Cuisine, 1 = Restaurants

  // "Why top-rated" labels for cuisine
  static const _cuisineReasons = [
    "#1 Bestseller",
    "Chef's Pick",
    "Fan Favourite",
    "Highly Rated",
    "Most Ordered",
  ];

  // "Why top-rated" labels for restaurants
  static const _restaurantReasons = [
    "Top Rated",
    "Fast & Fresh",
    "Guest Favourite",
    "Award Winning",
    "Crowd Pleaser",
  ];

  static const _reasonColors = [
    Color(0xFFFF6B6B), // coral
    Color(0xFF845EF7), // purple
    Color(0xFF339AF0), // blue
    Color(0xFF51CF66), // green
    Color(0xFFFF922B), // orange
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayItems = widget.displayCount != null
        ? widget.items.take(widget.displayCount!).toList()
        : widget.items;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // ── Header row ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.seeAll)
                    TextButton(
                      onPressed: () => context.pushNamed(
                        "allCouisineList",
                        extra: {
                          'title': widget.headingTitle,
                          'items': widget.items,
                        },
                      ),
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Pill tab switcher ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TopRatedTab(
                    label: "Best Cuisine",
                    icon: Icons.restaurant_menu_rounded,
                    isActive: _tab == 0,
                    color: colorScheme.primary,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  const SizedBox(width: 10),
                  _TopRatedTab(
                    label: "Top Restaurants",
                    icon: Icons.store_mall_directory_rounded,
                    isActive: _tab == 1,
                    color: colorScheme.primary,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
          ),

          // ── Cards (animated tab switch) ──
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _tab == 0
                  ? _CuisineCardList(
                      key: const ValueKey('cuisine'),
                      items: displayItems,
                      reasons: _cuisineReasons,
                      reasonColors: _reasonColors,
                      colorScheme: colorScheme,
                    )
                  : _RestaurantTabCardList(
                      key: const ValueKey('restaurant'),
                      items: restaurantsList.take(5).toList(),
                      reasons: _restaurantReasons,
                      reasonColors: _reasonColors,
                      colorScheme: colorScheme,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab pill button ────────────────────────────────────────────────────────────
class _TopRatedTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TopRatedTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? color
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? Colors.white
                  : cs.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cuisine cards horizontal list ─────────────────────────────────────────────
class _CuisineCardList extends StatelessWidget {
  final List<CuisineModel> items;
  final List<String> reasons;
  final List<Color> reasonColors;
  final ColorScheme colorScheme;

  const _CuisineCardList({
    super.key,
    required this.items,
    required this.reasons,
    required this.reasonColors,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final reason = reasons[index % reasons.length];
          final reasonColor = reasonColors[index % reasonColors.length];
          return GestureDetector(
            onTap: () => context.pushNamed("cuisineSingleItem", extra: item),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.25,
                      )
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                        item.image,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white.withValues(alpha: .2),
                          child: Text(
                            countries
                                .firstWhere(
                                  (c) => c.name == item.country,
                                  orElse: () => countries.first,
                                )
                                .flag,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),

                      // WHY badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: reasonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reason,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      // star rating
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Rs. ${item.price}",
                                  style: GoogleFonts.poppins(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
}

// ── Restaurant cards for Top Rated tab ────────────────────────────────────────
class _RestaurantTabCardList extends StatelessWidget {
  final List<RestaurantModel> items;
  final List<String> reasons;
  final List<Color> reasonColors;
  final ColorScheme colorScheme;

  const _RestaurantTabCardList({
    super.key,
    required this.items,
    required this.reasons,
    required this.reasonColors,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final r = items[index];
          final reason = reasons[index % reasons.length];
          final reasonColor = reasonColors[index % reasonColors.length];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantMenuScreen(restaurant: r),
              ),
            ),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(r.image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black12, Colors.black87],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: reasonColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reason,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              r.rating,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              r.deliveryTime,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 10,
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
        },
      ),
    );
  }
}

class SliverRestaurantCards extends StatelessWidget {
  final String headingTitle;
  final List<RestaurantModel> items;
  final int? displayCount;
  final bool seeAll;

  const SliverRestaurantCards({
    super.key,
    required this.headingTitle,
    required this.items,
    this.displayCount,
    this.seeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayItems = displayCount != null
        ? items.take(displayCount!).toList()
        : items;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (seeAll)
                    TextButton(
                      onPressed: () =>
                          context.pushNamed('exploreRestaurantsScreen'),
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final r = displayItems[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantMenuScreen(restaurant: r),
                      ),
                    ),
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(r.image, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                                stops: [0.4, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      r.rating,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Colors.white70,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      r.deliveryTime,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 10,
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularRestaurantCard extends StatelessWidget {
  final String name;
  final int index;
  final double radius;
  final Function onClick;

  const CircularRestaurantCard({
    super.key,
    required this.name,
    required this.index,
    required this.radius,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              onClick();
            },
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/${index + 200}/100/100',
              imageBuilder: (context, imageProvider) =>
                  CircleAvatar(radius: radius, backgroundImage: imageProvider),
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PremiumDrawerHeader extends StatelessWidget {
  final UserModel? user;
  const _PremiumDrawerHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E), // Deep Midnight
            colorScheme.primary.withValues(alpha: 0.9),
            const Color(0xFF16213E),
          ],
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final points = ref.watch(loyaltyProvider);
          final tier = MembershipRules.getTier(points);
          final tierName = MembershipRules.getTierName(tier);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.pushNamed('profileScreen', extra: user),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 35, // Compact size
                        backgroundColor: Colors.white10,
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/150?u=restrohub_user',
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email.split('@').first.toUpperCase() ??
                              'GUEST USER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          user?.email ?? 'guest@restrohub.com',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tierName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Loyalty Section - Vertically stacked for better modern look
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    _PointsGraph(collected: points.toDouble(), total: 2000),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$points',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'pts',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'LOYALTY PROGRESS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PointsGraph extends StatefulWidget {
  final double collected;
  final double total;
  const _PointsGraph({required this.collected, required this.total});

  @override
  State<_PointsGraph> createState() => _PointsGraphState();
}

class _PointsGraphState extends State<_PointsGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.collected / widget.total,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_PointsGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collected != widget.collected) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.collected / widget.total,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(80, 45), // More compact arc
          painter: _HalfArcPainter(
            progress: _animation.value,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            themePrimary: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _HalfArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final Color themePrimary;

  _HalfArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.themePrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.amber.shade300, Colors.white, Colors.amber.shade200],
      ).createShader(rect)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.5);

    // Subtle glow under the arc
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.2)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Draw background arc
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    if (progress > 0) {
      // Draw glow
      canvas.drawArc(rect, math.pi, math.pi * progress, false, glowPaint);
      // Draw progress arc
      canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
    }

    // RESTORED: Labels at the ends of the arc
    _drawArcLabel(canvas, center, radius, 'Gold', true);
    _drawArcLabel(canvas, center, radius, 'Platinum', false);

    // Percentage text - centered precisely
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - radius * 0.45, // Optimized position
      ),
    );
  }

  void _drawArcLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    bool isLeft,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.9),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = isLeft
        ? center.dx - radius - 2
        : center.dx + radius - tp.width + 2;
    final y = center.dy + 6;

    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _HalfArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ── Loading/Skeleton Widgets ──────────────────────────────────────────────────

class _SliverCountryCardsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Header skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 150, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 60, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          // Cards skeleton
          SliverToBoxAdapter(
            child: SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        ShimmerPlaceholder(
                          width: 100,
                          height: 100,
                          borderRadius: 12,
                        ),
                        const SizedBox(height: 8),
                        ShimmerPlaceholder(
                          width: 80,
                          height: 12,
                          borderRadius: 6,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverOfferCardsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Header skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 120, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 50, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          // Cards skeleton
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 160,
                      height: 180,
                      borderRadius: 16,
                      showText: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverRestaurantCardsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Header skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 180, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 50, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          // Cards skeleton
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 200,
                      height: 200,
                      borderRadius: 15,
                      showText: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTopRatedCardsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Header skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 100, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          // Tab skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerPlaceholder(width: 100, height: 35, borderRadius: 20),
                  ShimmerPlaceholder(width: 120, height: 35, borderRadius: 20),
                ],
              ),
            ),
          ),
          // Cards skeleton
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: ShimmerPlaceholder(
                      width: 170,
                      height: 250,
                      borderRadius: 22,
                      showText: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
