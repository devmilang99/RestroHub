import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/app_image.dart';

class ReviewCard extends StatelessWidget {
  final int index;
  final String name;
  final double rating;
  final String time;
  final String comment;
  final List<String> images;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    required this.index,
    required this.name,
    required this.rating,
    required this.time,
    required this.comment,
    required this.images,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(
            alpha: cs.brightness == Brightness.dark ? 0.6 : 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(
                  'https://i.pravatar.cc/150?u=user$index',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (name == 'You') ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit?.call();
                    }
                    if (val == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: cs.error,
                          ),
                          const SizedBox(width: 8),
                          const Text('Delete', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _openImageSlider(context, images, i),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    child: AppImage(
                      imagePath: images[i],
                      width: 70,
                      height: 70,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageSlider(BuildContext context, List<String> images, int index) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: Colors.black,
        builder: (context) =>
            ImageSliderDialog(images: images, initialIndex: index),
      ),
    );
  }
}

class ImageSliderDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const ImageSliderDialog({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  @override
  State<ImageSliderDialog> createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<ImageSliderDialog> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: AppImage(
                imagePath: widget.images[index],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
