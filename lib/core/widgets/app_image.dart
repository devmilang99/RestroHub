import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/core/utils/image_utils.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool optimize;
  final AppImageType type;

  const AppImage({
    required this.imagePath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.optimize = true,
    this.type = AppImageType.custom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    Widget image;
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      final int? effectiveWidth = (width != null && width!.isFinite)
          ? width!.toInt()
          : null;
      final int? effectiveHeight = (height != null && height!.isFinite)
          ? height!.toInt()
          : null;

      final String effectiveUrl;
      if (optimize) {
        switch (type) {
          case AppImageType.banner:
            effectiveUrl = ImageUtils.getRestaurantBanner(imagePath);
            break;
          case AppImageType.thumbnail:
            effectiveUrl = ImageUtils.getRestaurantThumbnail(imagePath);
            break;
          case AppImageType.menuItem:
            effectiveUrl = ImageUtils.getMenuItemImage(imagePath);
            break;
          case AppImageType.custom:
          case AppImageType.cuisine:
          case AppImageType.profile:
            effectiveUrl = ImageUtils.getOptimizedUrl(
              imagePath,
              width: effectiveWidth,
              height: effectiveHeight,
            );
            break;
        }
      } else {
        effectiveUrl = imagePath;
      }

      image = CachedNetworkImage(
        imageUrl: effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        // Using the base imagePath as the cacheKey ensures that if we've downloaded
        // any version of this image, we can potentially reuse it or avoid redundant lookups.
        // Note: Only use this if you want to prioritize speed over getting the absolute
        // latest optimized version for the specific dimensions.
        cacheKey: optimize ? null : imagePath,
        memCacheWidth: effectiveWidth != null
            ? ((effectiveWidth * 2 / 100).ceil() * 100) // Round to nearest 100
            : 800,
        memCacheHeight: effectiveHeight != null
            ? ((effectiveHeight * 2 / 100).ceil() * 100)
            : null,
        fadeOutDuration: const Duration(milliseconds: 300),
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          child: Center(
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Icon(
            Icons.broken_image_outlined,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
    } else if (imagePath.startsWith('assets/')) {
      image = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Icon(
            Icons.broken_image_outlined,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
    } else {
      image = Container(
        width: width,
        height: height,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
