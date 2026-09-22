import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../menu/controller/menu_controller.dart';

class CategoryList extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategoryChanged;

  const CategoryList({
    super.key,
    required this.selectedIndex,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _categoryKeys = {};

  GlobalKey _getKey(int index) {
    return _categoryKeys.putIfAbsent(
      index,
          () => GlobalKey(),
    );
  }

  @override
  void didUpdateWidget(
      covariant CategoryList oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final String title = isAll
              ? "All types"
              : categories[index - 1].name;

          final bool selected = widget.selectedIndex == index;

          return Container(
            key: _getKey(index),
            child: GestureDetector(
              onTap: () {
                widget.onCategoryChanged(index);
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xff2A2B2F),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}