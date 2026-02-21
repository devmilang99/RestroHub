import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/country_model.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restro_hub/core/widgets/searchable_sliver_app_layout.dart';

class CountryListScreen extends StatelessWidget {
  const CountryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── Subtle background texture ──
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CachedNetworkImage(
                imageUrl:
                    "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=1500&auto=format&fit=crop",
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: colorScheme.surface),
              ),
            ),
          ),

          // ── Reusable Searchable Layout ──
          SearchableSliverAppLayout<Country>(
            items: countries,
            title: "Global Cuisines",
            hintText: "Search countries or regions…",
            expandedHeight: 260,
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
            enableFilters: true,
            filterItems: const ['All', 'Asia', 'Europe', 'Americas', 'Africa'],
            onFilterChanged: (selected) {
              // Handle filter changes - can expand to filter countries by region
              debugPrint('Selected filters: $selected');
            },
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.12),
                    colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.public,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore Cuisines',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            filterPredicate: (country, query) =>
                country.name.toLowerCase().contains(query.toLowerCase()),
            itemBuilder: (context, country, index) {
              final cuisineCount = cuisines
                  .where((c) => c.country == country.name)
                  .length;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Card(
                        elevation: isDark ? 0 : 8,
                        shadowColor: colorScheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.pushNamed(
                            'exploreScreen',
                            extra: country.name,
                          ),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  country.historicalImage,
                                ),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.45),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              country.flag,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  country.name,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                Text(
                                                  "$cuisineCount+ Authentic Dishes",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
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
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
