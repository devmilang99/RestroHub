import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/User.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restro_hub/core/providers/cart_provider.dart';
import 'package:restro_hub/core/widgets/cart_bottom_sheet.dart';

import 'package:restro_hub/login/screens/Orders/orders_screen.dart';

class MainDashBoard extends ConsumerStatefulWidget {
  final User? user;
  const MainDashBoard({super.key, this.user});

  @override
  ConsumerState<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends ConsumerState<MainDashBoard> {
  int _currentIndex = 0;

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
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password'),
                      onTap: () {
                        context.pushNamed('forgotPasswordScreen');
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
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
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
                label: const Text("1"),
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
        // Cuisine Horizontal List
        SliverVerticalCards(
          headingTitle: 'Explore by Cuisine',
          isHorizontal: true,
          isCircular: true,
          items: cuisines,
          seeAll: true,
        ),

        SliverVerticalCards(
          headingTitle: 'Latest Offers',
          hasOffer: true,
          isHorizontal: true,
          isCircular: false,
          offerPercent: "20%",
          rating: "4.5",
          items: latestOffers,
          seeAll: true,
        ),

        SliverVerticalCards(
          headingTitle: 'Explore by Restaurant',
          isHorizontal: true,
          isCircular: true,
          items: restaurants,
          seeAll: true,
        ),

        SliverVerticalCards(
          headingTitle: 'Favourites',
          isHorizontal: true,
          isCircular: false,
          items: restaurants,
          seeAll: true,
          hasOffer: true,
          offerPercent: "20%",
          rating: "4.5",
        ),

        SliverVerticalCards(
          headingTitle: 'Top Rated',
          hasOffer: true,
          isHorizontal: false,
          isCircular: false,
          offerPercent: "80%",
          rating: "4.5",
          items: latestOffers,
          seeAll: true,
        ),
      ],
    );
  }
}

// Mock Data for demonstration
final List<Map<String, String>> cuisines = [
  {'name': 'Italian', 'image': 'assets/food1.webp'},
  {'name': 'Chinese', 'image': 'assets/food2.webp'},
  {'name': 'Mexican', 'image': 'assets/food3.webp'},
  {'name': 'Indian', 'image': 'assets/food4.webp'},
  {'name': 'Thai', 'image': 'assets/food5.webp'},
  {'name': 'Burger', 'image': 'assets/food6.webp'},
];

final List<Map<String, String>> latestOffers = [
  {'name': 'Italian 1', 'image': 'assets/food1.webp'},
  {'name': 'Chinese 2', 'image': 'assets/food2.webp'},
  {'name': 'Mexican 3', 'image': 'assets/food3.webp'},
  {'name': 'Indian 4', 'image': 'assets/food4.webp'},
  {'name': 'Thai 5', 'image': 'assets/food5.webp'},
  {'name': 'Burger 6', 'image': 'assets/food6.webp'},
];

final List<Map<String, String>> restaurants = [
  {'name': 'RoadSide D. Cafe', 'image': 'assets/food1.webp'},
  {'name': 'Airakan', 'image': 'assets/food2.webp'},
  {'name': 'Tasty Heaven', 'image': 'assets/food3.webp'},
  {'name': 'Thamel Restro', 'image': 'assets/food4.webp'},
  {'name': 'Unique Hub', 'image': 'assets/food5.webp'},
  {'name': 'A1 Cafe', 'image': 'assets/food6.webp'},
];

class SliverVerticalCards extends StatelessWidget {
  final String headingTitle;
  final bool hasOffer;
  final bool isHorizontal;
  final bool isCircular;
  final String offerPercent;
  final String rating;
  final bool seeAll;
  final List<Map<String, String>> items;

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
  });

  @override
  Widget build(BuildContext context) {
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
                        context.pushNamed("allCouisineList");
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return CircularRestaurantCard(
                      onClick: () {
                        context.pushNamed("cuisineSingleItem");
                      },
                      name: items[index]['name']!,
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return RestaurantCard(
                      onClick: () {
                        context.pushNamed("cuisineSingleItem");
                      },
                      name: items[index]['name']!,
                      index: index,
                      hasOffer: hasOffer,
                      offerPercent: offerPercent,
                      rating: rating,
                      width: 200,
                      image: items[index]['image']!,
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
                    context.pushNamed("cuisineSingleItem");
                  },
                  name: items[index]['name']!,
                  index: index,
                  hasOffer: hasOffer,
                  offerPercent: offerPercent,
                  rating: rating,
                  width: double.infinity,
                  image: items[index]['image']!,
                );
              }, childCount: items.length),
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
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {
          onClick();
        },
        child: Card(
          margin: const EdgeInsets.only(right: 16, bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
              placeholder: (context, url) => CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.restaurant, color: Colors.grey),
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
