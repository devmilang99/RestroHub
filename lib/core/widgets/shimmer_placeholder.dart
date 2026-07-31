import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool showText;

  const ShimmerPlaceholder({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = 0,
    this.showText = true,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.showText) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (mounted) {
          setState(() {
            _dotCount = (_dotCount + 1) % 4;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final dots = '.' * _dotCount;

    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        ),
        if (widget.showText && widget.height > 60)
          Text(
            'Loading$dots',
            style: GoogleFonts.poppins(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
