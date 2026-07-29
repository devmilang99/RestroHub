import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    required this.imagePath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    Widget image;
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      image = CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
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
