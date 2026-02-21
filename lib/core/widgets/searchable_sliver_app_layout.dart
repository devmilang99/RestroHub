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
  final Widget Function(
    BuildContext context,
    Set<String> selected,
    ValueChanged<Set<String>> onChanged,
  )?
  customFilterBuilder;
  final bool enableFilters;
  final List<String>? filterItems;
  final ValueChanged<Set<String>>? onFilterChanged;
  final String hintText;
  final double expandedHeight;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const SearchableSliverAppLayout({
    super.key,
    required this.items,
    required this.filterPredicate,
    required this.itemBuilder,
    required this.title,
    this.enableFilters = false,
    this.filterItems,
    this.onFilterChanged,
    this.customFilterBuilder,
    this.heroTag = 'title',
    this.background,
    this.filterBar,
    this.hintText = 'Search...',
    this.expandedHeight = 220,
    this.onBackPressed,
    this.showBackButton = true,
    this.actions,
    this.padding,
    this.physics,
  }) : assert(
         !enableFilters || (filterItems != null),
         'filterItems is required when enableFilters is true',
       );

  @override
  State<SearchableSliverAppLayout<T>> createState() =>
      _SearchableSliverAppLayoutState<T>();
}

class _SearchableSliverAppLayoutState<T>
    extends State<SearchableSliverAppLayout<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = "";
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedFilters = <String>{};
  bool _isCollapsed = false;
  bool _showBackToTop = false;

  double get _collapseTarget => widget.expandedHeight;

  double get _headerHeight =>
      (widget.filterBar != null ||
          (widget.enableFilters && (widget.filterItems?.isNotEmpty ?? false)))
      ? 120.0
      : 70.0;

  void _safeAnimateTo(
    double to, {
    int duration = 300,
    Curve curve = Curves.easeInOut,
  }) {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        to.clamp(0.0, max),
        duration: Duration(milliseconds: duration),
        curve: curve,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
    // When search gains focus, collapse the expanded app bar completely
    _searchFocus.addListener(() {
      final hasFocus = _searchFocus.hasFocus;
      if (hasFocus) {
        if (_scrollController.hasClients) {
          _safeAnimateTo(_collapseTarget, duration: 300);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _safeAnimateTo(_collapseTarget, duration: 300);
          });
        }
      } else {
        // When search loses focus and user is near top, re-expand app bar
        if (_scrollController.hasClients && _scrollController.offset < 30) {
          _safeAnimateTo(0, duration: 300);
        }
      }
    });

    // scroll listener: track collapsed state and re-expand when near top
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset >= (_collapseTarget - 2.0);
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }

      // show back-to-top button when scrolled well past the collapsed header
      final showTop = _scrollController.offset > (_collapseTarget + 100);
      if (showTop != _showBackToTop) setState(() => _showBackToTop = showTop);

      if (!_searchFocus.hasFocus && _scrollController.offset < 30) {
        if (_scrollController.position.pixels > 0) {
          _safeAnimateTo(0, duration: 200, curve: Curves.easeOut);
        }
      }
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = widget.items
        .where((item) => widget.filterPredicate(item, _query))
        .toList();

    final hasFilterItems =
        widget.enableFilters && (widget.filterItems?.isNotEmpty ?? false);

    final List<Widget> _filterChipWidgets = hasFilterItems
        ? widget.filterItems!.map((f) {
            final selected = _selectedFilters.contains(f);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedFilters.add(f);
                    } else {
                      _selectedFilters.remove(f);
                    }
                  });
                  widget.onFilterChanged?.call(_selectedFilters);
                },
              ),
            );
          }).toList()
        : const <Widget>[];
    final headerHeight = _headerHeight;

    return Stack(
      children: [
        NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            final collapseTarget = widget.expandedHeight;
            final offset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            if (offset > 0 && offset < collapseTarget) {
              final mid = collapseTarget / 2;
              final to = offset >= mid ? collapseTarget : 0.0;
              _safeAnimateTo(to, duration: 250, curve: Curves.easeOut);
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: widget.physics ?? const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar (Expandable, Collapsible) ──
              SliverAppBar(
                expandedHeight: widget.expandedHeight,
                collapsedHeight: kToolbarHeight,
                toolbarHeight: kToolbarHeight,
                pinned: false,
                floating: false,
                snap: false,
                elevation: 0,
                backgroundColor: colorScheme.surface,
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
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            if (widget.enableFilters)
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.tune,
                                      color: colorScheme.onSurface,
                                    ),
                                    onPressed: _showFilterSheet,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                ),
              ),

              // ── Pinned Search Bar with Back & Filter ──
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchHeaderDelegate(
                  height: headerHeight,
                  child: Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Back Button + Search + Filter Icon in one row
                        Row(
                          children: [
                            // Back Button: only visible when header is fully collapsed
                            if (widget.showBackButton && _isCollapsed)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: colorScheme.onSurface,
                                  ),
                                  onPressed:
                                      widget.onBackPressed ??
                                      () => Navigator.pop(context),
                                ),
                              ),
                            // Search Field
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
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
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
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                            ),
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
                            // Filter Icon
                            if (widget.enableFilters)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.tune,
                                    color: colorScheme.onSurface,
                                  ),
                                  onPressed: _showFilterSheet,
                                ),
                              ),
                          ],
                        ),
                        // Filter Chips or Custom Filter Builder
                        if (widget.filterBar != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: widget.filterBar!,
                            ),
                          )
                        else if (widget.customFilterBuilder != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: widget.customFilterBuilder!(
                                context,
                                _selectedFilters,
                                (selected) {
                                  setState(() {
                                    _selectedFilters.clear();
                                    _selectedFilters.addAll(selected);
                                  });
                                  widget.onFilterChanged?.call(
                                    _selectedFilters,
                                  );
                                },
                              ),
                            ),
                          )
                        else if (hasFilterItems)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: _filterChipWidgets),
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
          ),
        ),
        // Floating "back to top" button
        if (_showBackToTop)
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                _searchFocus.unfocus();
                _safeAnimateTo(0, duration: 400, curve: Curves.easeInOut);
                setState(() {
                  _showBackToTop = false;
                });
              },
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
      ],
    );
  }

  void _showFilterSheet() {
    if (!(widget.filterItems?.isNotEmpty ?? false)) return;
    final colorScheme = context.colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tempSelected = Set<String>.from(_selectedFilters);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => tempSelected.clear());
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: widget.filterItems!.map((f) {
                      final isSelected = tempSelected.contains(f);
                      return ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              tempSelected.add(f);
                            } else {
                              tempSelected.remove(f);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFilters
                            ..clear()
                            ..addAll(tempSelected);
                        });
                        widget.onFilterChanged?.call(_selectedFilters);
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
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
