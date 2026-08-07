import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final String? restaurantId;
  final int index;
  final bool isFirst;
  final bool isDark;
  final ColorScheme colorScheme;

  const MenuItemCard({
    required this.item,
    required this.index,
    required this.isFirst,
    required this.isDark,
    required this.colorScheme,
    this.restaurantId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => context.pushNamed('cuisineSingleItem', extra: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // thumbnail
            Card(
              elevation: 0,
              child: Hero(
                tag: 'food_${item.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: AppImage(
                    imagePath: item.imageUrl ?? '',
                    width: 108,
                    height: 108,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.black12,
            ),
            // details
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // badge (signature for first item)
                        if (isFirst)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Best Dish',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                fontSize: 8,
                                color: Colors.deepOrange,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Favourite Icon
                        Consumer(
                          builder: (context, ref, _) {
                            final isFavourited = ref.watch(
                              isFavouriteProvider(item.id),
                            );
                            return GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(favouritesProvider.notifier)
                                    .toggleFavourite(item);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isFavourited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFavourited
                                      ? Colors.red
                                      : cs.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // name
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // description
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // price and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${item.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: cs.primary,
                          ),
                        ),
                        Material(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(
                                    CartModel(
                                      id: item.id,
                                      restaurantId: restaurantId,
                                      name: item.name,
                                      price: item.price,
                                      image: item.imageUrl ?? '',
                                      quantity: 1,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.addedToCart(item.name)),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
