import 'package:flutter/material.dart';
import 'package:restro_hub/core/widgets/shimmer_placeholder.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverCountryCardsSkeleton(),
        SliverOfferCardsSkeleton(),
        SliverRestaurantCardsSkeleton(),
      ],
    );
  }
}

class SliverCountryCardsSkeleton extends StatelessWidget {
  const SliverCountryCardsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 150, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 60, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        ShimmerPlaceholder(
                          width: 100,
                          height: 100,
                          borderRadius: 12,
                        ),
                        SizedBox(height: 8),
                        ShimmerPlaceholder(
                          width: 80,
                          height: 12,
                          borderRadius: 6,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverOfferCardsSkeleton extends StatelessWidget {
  const SliverOfferCardsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 120, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 50, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 160,
                      height: 180,
                      borderRadius: 16,
                      showText: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverRestaurantCardsSkeleton extends StatelessWidget {
  const SliverRestaurantCardsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 24, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholder(width: 180, height: 20, borderRadius: 8),
                  ShimmerPlaceholder(width: 50, height: 20, borderRadius: 8),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 200,
                      height: 200,
                      borderRadius: 15,
                      showText: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverGridSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;

  const SliverGridSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => ShimmerPlaceholder(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 24,
          showText: index == 0,
        ),
        childCount: itemCount,
      ),
    );
  }
}

class SliverListSkeleton extends StatelessWidget {
  final int itemCount;
  final double height;

  const SliverListSkeleton({
    super.key,
    this.itemCount = 6,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerPlaceholder(
            width: double.infinity,
            height: height,
            borderRadius: 24,
            showText: index == 0,
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}
