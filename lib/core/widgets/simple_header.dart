import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? watermarkIcon;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;

  const SimpleHeader({
    required this.title,
    super.key,
    this.watermarkIcon,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary,
            isDark
                ? colorScheme.primary.withValues(alpha: 0.8)
                : colorScheme.primary.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (watermarkIcon != null)
            Positioned(
              right: -30,
              top: -10,
              child: Icon(
                watermarkIcon,
                size: 180,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBackButton)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 20),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
