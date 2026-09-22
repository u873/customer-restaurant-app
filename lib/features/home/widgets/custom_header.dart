import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:customer_estaurant_app/features/home/widgets/branch_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../branch/controller/branch_controller.dart';
import '../../menu/controller/menu_controller.dart';

class CustomHeader extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSearchStateChanged;

  const CustomHeader({
    super.key,
    required this.onSearchChanged,
    required this.onSearchStateChanged,
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });

    widget.onSearchStateChanged(true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    widget.onSearchChanged("");
    setState(() {
      _isSearching = false;
    });

    widget.onSearchStateChanged(false);
  }

  void _openBranchSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) {
        return const BranchSelectionSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    final branchController = context.watch<BranchController>();
    final branch =
        branchController.selectedBranch ?? menuProvider.nearestBranch;

    return Container(
      width: double.infinity,
      color: const Color(0xff191A1E),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          );
        },
        child: _isSearching
            ? _buildSearchBar()
            : _buildNormalHeader(context, menuProvider, branch),
      ),
    );
  }

  Widget _buildNormalHeader(
    BuildContext context,
    MenuProvider menuProvider,
    dynamic branch,
  ) {
    return Row(
      key: const ValueKey("normalHeader"),
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _openBranchSelection,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuProvider.selectedOrderType == OrderType.delivery
                      ? "Delivery From"
                      : "Pick-Up From",

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        branch?.name ?? "Finding nearest branch...",

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        InkWell(
          borderRadius: BorderRadius.circular(30),

          onTap: _openSearch,

          child: Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(color: Colors.white38),
            ),

            child: const Icon(Icons.search, color: Colors.white, size: 21),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      key: const ValueKey("searchHeader"),
      height: 44,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,

        onChanged: widget.onSearchChanged,

        cursorColor: AppColors.primary,

        style: const TextStyle(color: Colors.white, fontSize: 14),

        decoration: InputDecoration(
          hintText: "Search food...",

          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),

          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 21),

          suffixIcon: InkWell(
            borderRadius: BorderRadius.circular(30),

            onTap: _closeSearch,

            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          filled: true,

          fillColor: const Color(0xff292A2D),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),

            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),

            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),

            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
      ),
    );
  }
}
