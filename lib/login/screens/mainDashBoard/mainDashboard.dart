import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/User.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restro_hub/core/providers/cart_provider.dart';
import 'package:restro_hub/core/providers/favourites_provider.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:restro_hub/core/widgets/cart_bottom_sheet.dart';
import 'package:restro_hub/login/screens/Orders/orders_screen.dart';
import 'package:restro_hub/core/models/cuisines_item.dart';
import 'package:restro_hub/core/models/country_model.dart';
import 'package:restro_hub/core/models/restaurant_model.dart';
import 'package:restro_hub/login/screens/restaurant_menu_screen.dart';
import 'package:restro_hub/core/data/mock_data.dart';

class MainDashBoard extends ConsumerStatefulWidget {
  final User? user;
  const MainDashBoard({super.key, this.user});

  @override
  ConsumerState<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends ConsumerState<MainDashBoard> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

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
    final totalItems = cart.fold(0, (sum, item) => sum + item.quantity);

    final List<Widget> pages = [
      _buildHomeView(context, colorScheme),
      const SizedBox.shrink(), // Placeholder for Cart (handled via bottom sheet)
      const OrdersScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          context.goNamed('mainLoginScreen');
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
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Home'),
                      onTap: () {
                        context.pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.explore_outlined),
                      title: const Text('Explore'),
                      onTap: () {
                        context.pop();
                        context.pushNamed('exploreScreen');
                      },
                    ),
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
                        // Contact support logic
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_rounded),
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
          expandedHeight: 140,
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
          title: Column(
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
                  Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Badge(
                label: const Text("3"),
                child: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface,
                ),
              ),
              onPressed: () {},
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for food or restaurants",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
        ),
        // Countries Horizontal List
        SliverCountryCards(
          headingTitle: 'Explore by Cuisine',
          items: countries,
          displayCount: 6,
          seeAll: true,
        ),

        SliverOfferCards(
          headingTitle: 'Latest Offers',
          items: latestOffers,
          displayCount: 5,
          seeAll: true,
        ),

        SliverRestaurantCards(
          headingTitle: 'Explore by Restaurant',
          items: exploreRestaurants,
          displayCount: 5,
          seeAll: true,
        ),

        SliverTopRatedCards(
          headingTitle: 'Top Rated Dishes',
          items: topRated,
          displayCount: 5,
          seeAll: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant,
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  "You've explored the best of Restro Hub!",
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Time to order something delicious!",
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
  final List<CuisinesItem> items;
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
  final List<Country> items;
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
                      onPressed: () {
                        context.pushNamed('countryListScreen');
                      },
                      child: const Text("See All"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final country = displayItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              'exploreScreen',
                              extra: country.name,
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                country.flag,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          country.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

class SliverOfferCards extends StatelessWidget {
  final String headingTitle;
  final List<CuisinesItem> items;
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

class SliverTopRatedCards extends StatelessWidget {
  final String headingTitle;
  final List<CuisinesItem> items;
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
                    ),
                  ),
                  Visibility(
                    visible: seeAll,
                    child: TextButton(
                      onPressed: () => context.pushNamed(
                        "allCouisineList",
                        extra: {'title': headingTitle, 'items': items},
                      ),
                      child: const Text("See All"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
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
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
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
                          Expanded(
                            child: Stack(
                              children: [
                                Image.asset(
                                  item.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.rating,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
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

class SliverRestaurantCards extends StatelessWidget {
  final String headingTitle;
  final List<Restaurant> items;
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
                      onPressed: () {
                        context.pushNamed('exploreRestaurantsScreen');
                      },
                      child: const Text("See All"),
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
                padding: const EdgeInsets.all(8.0),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final restaurant = displayItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RestaurantMenuScreen(restaurant: restaurant),
                        ),
                      );
                    },
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Image.asset(
                            restaurant.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.rating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      restaurant.deliveryTime,
                                      style: const TextStyle(
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
  final User? user;
  const _PremiumDrawerHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
            Colors.orange.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=restrohub_user',
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      user?.email ?? 'guest@restrohub.com',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Gold Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PointsGraph(collected: 750, total: 1000),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '750',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Loyalty Points',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.transparent,
                ),
              ),
              CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 5,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeCap: StrokeCap.round,
              ),
              Text(
                '${(widget.collected / widget.total * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
