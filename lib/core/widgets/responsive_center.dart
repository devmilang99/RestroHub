import 'package:flutter/material.dart';
import 'package:restro_hub/core/utils/responsive_utils.dart';

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    required this.child,
    super.key,
    this.maxWidth = ResponsiveBreakpoints.tablet,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class SliverResponsiveCenter extends StatelessWidget {
  final Widget sliver;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const SliverResponsiveCenter({
    required this.sliver,
    super.key,
    this.maxWidth = ResponsiveBreakpoints.tablet,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              slivers: [sliver],
            ),
          ),
        ),
      ),
    );
  }
}
