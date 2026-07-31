import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';

final favouriteSearchProvider = StateProvider<String>((ref) => '');

class ShowFavourites extends ConsumerWidget {
  const ShowFavourites({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouritesProvider);
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: favsAsync.when(
        data: (favs) {
          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          return _FavouritesList(favs: favs);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _FavouritesList extends ConsumerWidget {
  final List<MenuItemModel> favs;
  const _FavouritesList({required this.favs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(favouriteSearchProvider);

    final filtered = favs.where((item) {
      return item.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty && searchQuery.isNotEmpty) {
      return const Center(
        child: Text('No matching favorites found'),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: _FavouriteCard(
                  item: filtered[index],
                  index: index,
                  onRemove: () {
                    unawaited(
                      ref
                          .read(favouritesProvider.notifier)
                          .toggleFavourite(filtered[index]),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  final MenuItemModel item;
  final int index;
  final VoidCallback onRemove;

  const _FavouriteCard({
    required this.item,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image
            Hero(
              tag: 'item_${item.name}_${item.imageUrl}',
              child: SizedBox(
                width: 100,
                child: (item.imageUrl?.startsWith('http') ?? false)
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Image.asset(
                        item.imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${item.price}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: onRemove,
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    // Add to cart logic
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
