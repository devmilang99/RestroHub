import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class SearchableSliverAppLayout<T> extends StatefulWidget {
  final List<T> items;
  final bool Function(T item, String query) filterPredicate;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String title;
  final String heroTag;
  final Widget? background;
  final Widget? filterBar;
  final String hintText;
  final double expandedHeight;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const SearchableSliverAppLayout({
    super.key,
    required this.items,
    required this.filterPredicate,
    required this.itemBuilder,
    required this.title,
    this.heroTag = 'title',
    this.background,
    this.filterBar,
    this.hintText = 'Search...',
    this.expandedHeight = 220,
    this.leading,
    this.actions,
    this.padding,
    this.physics,
  });

  @override
  State<SearchableSliverAppLayout<T>> createState() =>
      _SearchableSliverAppLayoutState<T>();
}

class _SearchableSliverAppLayoutState<T>
    extends State<SearchableSliverAppLayout<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = widget.items
        .where((item) => widget.filterPredicate(item, _query))
        .toList();

    return CustomScrollView(
      physics: widget.physics ?? const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar (Expandable, Collapsible) ──
        SliverAppBar(
          expandedHeight: widget.expandedHeight,
          collapsedHeight: kToolbarHeight,
          toolbarHeight: kToolbarHeight,
          pinned: false,
          floating: true,
          snap: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: widget.leading,
          actions: widget.actions,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            collapseMode: CollapseMode.parallax,
            background:
                widget.background ??
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.secondary.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
          ),
        ),

        // ── Pinned Search Bar ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchHeaderDelegate(
            height: widget.filterBar != null ? 120 : 70,
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              hintStyle: GoogleFonts.poppins(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.primary,
                              ),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.filterBar != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: widget.filterBar!,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── List Content ──
        SliverPadding(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: filteredItems.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No results found",
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => widget.itemBuilder(
                      context,
                      filteredItems[index],
                      index,
                    ),
                    childCount: filteredItems.length,
                  ),
                ),
        ),

        // ── Bottom Spacing ──
        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SearchHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
