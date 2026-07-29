import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final int index;
  final bool hasOffer;
  final String offerPercent;
  final String rating;
  final double width;
  final VoidCallback onClick;
  final String image;

  const RestaurantCard({
    required this.name,
    required this.index,
    required this.width,
    required this.onClick,
    required this.image,
    super.key,
    this.hasOffer = false,
    this.offerPercent = '',
    this.rating = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        child: GestureDetector(
          onTap: onClick,
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
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.startsWith('http'))
                  Image.network(
                    image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ShimmerPlaceholder(
                      width: double.infinity,
                      height: 160,
                    ),
                  )
                else if (image.isNotEmpty)
                  Image.asset(
                    image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 400, // Optimization: downscale cache
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return frame != null
                              ? child
                              : const ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 160,
                                );
                        },
                    errorBuilder: (_, _, _) => const ShimmerPlaceholder(
                      width: double.infinity,
                      height: 160,
                    ),
                  )
                else
                  const ShimmerPlaceholder(
                    width: double.infinity,
                    height: 160,
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class CircularRestaurantCard extends StatelessWidget {
  final String name;
  final int index;
  final double radius;
  final VoidCallback onClick;

  const CircularRestaurantCard({
    required this.name,
    required this.index,
    required this.radius,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: onClick,
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/${index + 200}/100/100',
              memCacheWidth: 200, // Optimization
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
