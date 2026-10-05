import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:customer_estaurant_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../menu/controller/menu_controller.dart';

class CategoryList extends StatefulWidget {
  final int selectedIndex;
  final String searchQuery;
  final bool isSearching;
  final ValueChanged<int> onCategoryChanged;

  const CategoryList({
    super.key,
    required this.selectedIndex,
    this.searchQuery = '',
    required this.isSearching,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> _categoryKeys = {};

  GlobalKey _getKey(int index) {
    return _categoryKeys.putIfAbsent(index, () => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.isSearching != widget.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedCategory();
      });
    }
  }

  void _scrollToSelectedCategory() {
    final key = _categoryKeys[widget.selectedIndex];

    if (key?.currentContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  String _getCategoryImage(dynamic category) {
    final imageUrl = category.imageUrl?.toString().trim() ?? '';
    final image = category.image?.toString().trim() ?? '';

    if (imageUrl.isNotEmpty) {
      return imageUrl;
    }

    return image;
  }

  Widget _buildCategoryImage(dynamic category) {
    final image = _getCategoryImage(category);

    if (image.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.category_outlined,
          size: 20,
          color: Colors.white60,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 20,
              color: Colors.white60,
            ),
          );
        },
      ),
    );
  }

  bool _categoryMatchesSearch(dynamic category, String query) {
    if (query.isEmpty) {
      return true;
    }

    final categoryName = category.name.toString().toLowerCase();

    if (categoryName.contains(query)) {
      return true;
    }

    final menuItems = category.menu ?? [];

    return menuItems.any((item) {
      final name = item.name.toString().toLowerCase();
      final description = item.description?.toString().toLowerCase() ?? '';

      return name.contains(query) || description.contains(query);
    });
  }

  List<int> _getVisibleCategoryIndexes(List<dynamic> categories) {
    final query = widget.searchQuery.trim().toLowerCase();

    final indexes = <int>[];

    for (int i = 0; i < categories.length; i++) {
      if (_categoryMatchesSearch(categories[i], query)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    final bool searchActive =
        widget.isSearching || widget.searchQuery.trim().isNotEmpty;

    final visibleCategoryIndexes = searchActive
        ? _getVisibleCategoryIndexes(categories)
        : List<int>.generate(categories.length, (index) => index);

    return SizedBox(
      height: 60,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),

        // All types + filtered categories
        itemCount: visibleCategoryIndexes.length + 1,

        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final bool isAll = index == 0;

          final int? apiCategoryIndex = isAll
              ? null
              : visibleCategoryIndexes[index - 1];

          final String title = isAll
              ? "All types"
              : categories[apiCategoryIndex!].name;

          // IMPORTANT:
          // The selected index remains the original UI/API index.
          //
          // API index 0 -> UI index 1
          // API index 1 -> UI index 2
          // API index 2 -> UI index 3
          final int uiCategoryIndex = isAll ? 0 : apiCategoryIndex! + 1;

          final bool selected = widget.selectedIndex == uiCategoryIndex;

          return Container(
            key: _getKey(uiCategoryIndex),
            child: GestureDetector(
              onTap: () {
                if (widget.searchQuery.trim().isNotEmpty &&
                    uiCategoryIndex == 0) {
                  widget.onCategoryChanged(0);

                  return;
                }
                widget.onCategoryChanged(uiCategoryIndex);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(left: isAll ? 16 : 7, right: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : const Color(0xff2A2B2F),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll) ...[
                      _buildCategoryImage(categories[apiCategoryIndex!]),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      title,
                      style: AppTextStyles.action.copyWith(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
