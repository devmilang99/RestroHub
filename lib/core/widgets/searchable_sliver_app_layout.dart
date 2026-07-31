import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class SearchableSliverAppLayout<T> extends StatefulWidget {
  final List<T> items;
  final bool Function(T item, String query) filterPredicate;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String? title;
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
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool isLoading;
  final Widget? skeleton;
  final ValueChanged<String>? onSearchChanged;

  // Adaptive properties
  final bool isGrid;
  final SliverGridDelegate? gridDelegate;

  const SearchableSliverAppLayout({
    required this.items,
    required this.filterPredicate,
    required this.itemBuilder,
    required this.title,
    super.key,
    this.enableFilters = false,
    this.filterItems,
    this.onFilterChanged,
    this.customFilterBuilder,
    this.heroTag = 'title',
    this.background,
    this.filterBar,
    this.hintText = 'Search...',
    this.expandedHeight = 120,
    this.onBackPressed,
    this.showBackButton = true,
    this.actions,
    this.padding,
    this.physics,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.skeleton,
    this.onSearchChanged,
    this.isGrid = false,
    this.gridDelegate,
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
  String _query = '';
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedFilters = <String>{};
  bool _isCollapsed = false;
  bool _showBackToTop = false;

  double get _collapseTarget => widget.expandedHeight;

  double get _headerHeight {
    if (!widget.enableFilters) return 70;
    final hasFilterContent =
        widget.filterBar != null ||
        widget.customFilterBuilder != null ||
        (widget.filterItems?.isNotEmpty ?? false);
    return hasFilterContent ? 120.0 : 70.0;
  }

  void _safeAnimateTo(
    double to, {
    int duration = 300,
    Curve curve = Curves.easeInOut,
  }) {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      final target = to.clamp(0.0, max);

      if ((_scrollController.offset - target).abs() < 1.0) return;

      unawaited(
        _scrollController.animateTo(
          target,
          duration: Duration(milliseconds: duration),
          curve: curve,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(() {
      final hasFocus = _searchFocus.hasFocus;
      if (hasFocus) {
        if (_scrollController.hasClients) {
          _safeAnimateTo(_collapseTarget);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _safeAnimateTo(_collapseTarget);
          });
        }
      } else {
        if (_scrollController.hasClients && _scrollController.offset < 30) {
          _safeAnimateTo(0);
        }
      }
    });

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset >= (_collapseTarget - 2.0);
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }

      final showTop = _scrollController.offset > (_collapseTarget + 100);
      if (showTop != _showBackToTop) setState(() => _showBackToTop = showTop);

      // Infinite scroll logic
      if (widget.onLoadMore != null && !widget.isLoadingMore) {
        final pos = _scrollController.position;
        if (pos.pixels > pos.maxScrollExtent * 0.85) {
          widget.onLoadMore!();
        }
      }
    });
  }

  Timer? _debounce;
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _query = _searchController.text;
        });
        widget.onSearchChanged?.call(_query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final filteredItems = widget.items
        .where((item) => widget.filterPredicate(item, _query))
        .toList();

    final headerHeight = _headerHeight;

    final effectivePadding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return SafeArea(
      child: Stack(
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
                SliverAppBar(
                  expandedHeight: widget.expandedHeight,
                  collapsedHeight: kToolbarHeight,
                  elevation: 0,
                  backgroundColor: colorScheme.surface,
                  actions: widget.actions,
                  flexibleSpace: FlexibleSpaceBar(
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
                                  widget.title!,
                                  style: GoogleFonts.poppins(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                              if (widget.enableFilters &&
                                  (widget.filterItems?.isNotEmpty ?? false))
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
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    height: headerHeight,
                    child: _SearchHeaderContent(
                      isCollapsed: _isCollapsed,
                      showBackButton: widget.showBackButton,
                      onBackPressed: widget.onBackPressed,
                      searchController: _searchController,
                      searchFocus: _searchFocus,
                      hintText: widget.hintText,
                      query: _query,
                      clearSearch: _clearSearch,
                      enableFilters: widget.enableFilters,
                      showFilterSheet: _showFilterSheet,
                      filterBar: widget.filterBar,
                      customFilterBuilder: widget.customFilterBuilder,
                      selectedFilters: _selectedFilters,
                      filterItems: widget.filterItems,
                      onFilterChanged: (selected) {
                        setState(() {
                          _selectedFilters
                            ..clear()
                            ..addAll(selected);
                        });
                        widget.onFilterChanged?.call(_selectedFilters);
                      },
                    ),
                  ),
                ),

                // ── Adaptive Content (List or Grid) ──
                SliverPadding(
                  padding: effectivePadding,
                  sliver: widget.isLoading && widget.skeleton != null
                      ? widget.skeleton!
                      : filteredItems.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No results found',
                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : (widget.isGrid
                            ? SliverGrid(
                                gridDelegate:
                                    widget.gridDelegate ??
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => widget.itemBuilder(
                                    context,
                                    filteredItems[index],
                                    index,
                                  ),
                                  childCount: filteredItems.length,
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
                              )),
                ),
                if (widget.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
          if (_showBackToTop)
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _searchFocus.unfocus();
                  _safeAnimateTo(0, duration: 400);
                  setState(() {
                    _showBackToTop = false;
                  });
                },
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    if (!widget.enableFilters || !(widget.filterItems?.isNotEmpty ?? false)) {
      return;
    }
    final colorScheme = context.colorScheme;
    unawaited(
      showModalBottomSheet<void>(
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
                          'Filters',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(tempSelected.clear);
                          },
                          child: const Text('Reset'),
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
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SearchHeaderContent extends StatelessWidget {
  final bool isCollapsed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final String hintText;
  final String query;
  final VoidCallback clearSearch;
  final bool enableFilters;
  final VoidCallback showFilterSheet;
  final Widget? filterBar;
  final Widget Function(
    BuildContext context,
    Set<String> selected,
    ValueChanged<Set<String>> onChanged,
  )?
  customFilterBuilder;
  final Set<String> selectedFilters;
  final List<String>? filterItems;
  final ValueChanged<Set<String>> onFilterChanged;

  const _SearchHeaderContent({
    required this.isCollapsed,
    required this.showBackButton,
    required this.onBackPressed,
    required this.searchController,
    required this.searchFocus,
    required this.hintText,
    required this.query,
    required this.clearSearch,
    required this.enableFilters,
    required this.showFilterSheet,
    required this.filterBar,
    required this.customFilterBuilder,
    required this.selectedFilters,
    required this.filterItems,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasFilterItems = enableFilters && (filterItems?.isNotEmpty ?? false);

    final filterChipWidgets = hasFilterItems
        ? filterItems!.map((f) {
            final selected = selectedFilters.contains(f);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (val) {
                  final newSelected = Set<String>.from(selectedFilters);
                  if (val) {
                    newSelected.add(f);
                  } else {
                    newSelected.remove(f);
                  }
                  onFilterChanged(newSelected);
                },
              ),
            );
          }).toList()
        : const <Widget>[];

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (showBackButton && isCollapsed)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  ),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          )
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
                    key: const ValueKey('search_textfield'),
                    controller: searchController,
                    focusNode: searchFocus,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: clearSearch,
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
              if (enableFilters)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: colorScheme.onSurface),
                    onPressed: showFilterSheet,
                  ),
                ),
            ],
          ),
          if (enableFilters) ...[
            if (filterBar != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: filterBar,
                ),
              )
            else if (customFilterBuilder != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: customFilterBuilder!(
                    context,
                    selectedFilters,
                    onFilterChanged,
                  ),
                ),
              )
            else if (hasFilterItems)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: filterChipWidgets),
                ),
              ),
          ],
        ],
      ),
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
    // Optimization: Check for equality to prevent unnecessary semantics updates
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
