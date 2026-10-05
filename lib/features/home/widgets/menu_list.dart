import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/food_card.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/model/cart_item.dart';
import '../../menu/controller/menu_controller.dart';
import '../../menu/model/main_data_response.dart';

class MenuList extends StatefulWidget {
  final int selectedCategoryIndex;
  final String searchQuery;
  final bool isSearching;

  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<Menu> onProductTap;
  final ValueChanged<Menu> onDealTap;

  const MenuList({
    super.key,
    required this.selectedCategoryIndex,
    required this.searchQuery,
    required this.isSearching,
    required this.onCategoryChanged,
    required this.onProductTap,
    required this.onDealTap,
  });

  @override
  State<MenuList> createState() => MenuListState();
}

class _MenuEntry {
  final Menu item;
  final int apiCategoryIndex;

  const _MenuEntry({required this.item, required this.apiCategoryIndex});
}

class MenuListState extends State<MenuList> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isScrollingFromCategory = false;

  int? _addingItemId;

  @override
  void initState() {
    super.initState();

    _itemPositionsListener.itemPositions.addListener(_onItemsChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onItemsChanged);

    super.dispose();
  }

  List<_MenuEntry> _buildMenuEntries(List<RestaurantBranchMenu> categories) {
    final entries = <_MenuEntry>[];

    for (
      int categoryIndex = 0;
      categoryIndex < categories.length;
      categoryIndex++
    ) {
      for (final item in categories[categoryIndex].menu) {
        entries.add(_MenuEntry(item: item, apiCategoryIndex: categoryIndex));
      }
    }

    return entries;
  }

  List<_MenuEntry> _filterMenuEntries(List<_MenuEntry> entries) {
    final query = widget.searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return entries;
    }

    return entries.where((entry) {
      final name = entry.item.name.toLowerCase();
      final description = entry.item.description?.toLowerCase() ?? '';

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  CartItem? _getCartItem(CartProvider cartProvider, int menuId) {
    for (final cartItem in cartProvider.cartItems) {
      if (cartItem.menuId == menuId) {
        return cartItem;
      }
    }

    return null;
  }

  void scrollToCategory(int categoryIndex) {
    final provider = context.read<MenuProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    if (provider.isLoading || categories.isEmpty) {
      return;
    }

    if (!_itemScrollController.isAttached) {
      return;
    }

    final allEntries = _buildMenuEntries(categories);
    final entries = _filterMenuEntries(allEntries);

    // All types
    if (categoryIndex == 0) {
      if (entries.isEmpty) {
        return;
      }

      _isScrollingFromCategory = true;

      _itemScrollController
          .scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      )
          .whenComplete(() {
        _isScrollingFromCategory = false;
      });

      return;
    }

    final apiCategoryIndex = categoryIndex - 1;

    // Search ke waqt filtered list mein is category ka
    // pehla matching item find karo.
    final itemIndex = entries.indexWhere(
          (entry) => entry.apiCategoryIndex == apiCategoryIndex,
    );

    if (itemIndex == -1) {
      return;
    }

    _isScrollingFromCategory = true;

    _itemScrollController
        .scrollTo(
      index: itemIndex,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      _isScrollingFromCategory = false;
    });
  }

  void _onItemsChanged() {
    if (_isScrollingFromCategory) {
      return;
    }

    final provider = context.read<MenuProvider>();

    if (provider.isLoading) {
      return;
    }

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    if (categories.isEmpty) {
      return;
    }

    final positions = _itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) {
      return;
    }

    final visibleItems = positions
        .where(
          (position) =>
              position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
        )
        .toList();

    if (visibleItems.isEmpty) {
      return;
    }

    visibleItems.sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    final currentItemIndex = visibleItems.first.index;

    final allEntries = _buildMenuEntries(categories);
    final filteredEntries = _filterMenuEntries(allEntries);

    if (currentItemIndex < 0 || currentItemIndex >= filteredEntries.length) {
      return;
    }

    final apiCategoryIndex = filteredEntries[currentItemIndex].apiCategoryIndex;

    final newCategoryIndex = apiCategoryIndex + 1;

    if (newCategoryIndex != widget.selectedCategoryIndex) {
      widget.onCategoryChanged(newCategoryIndex);
    }
  }

  String _getItemImage(Menu item, List<RestaurantBranchMenu> categories) {
    final itemImageUrl = item.imageUrl ?? '';

    if (itemImageUrl.trim().isNotEmpty) {
      return itemImageUrl;
    }

    final itemImage = item.image ?? '';

    if (itemImage.trim().isNotEmpty) {
      return itemImage;
    }

    for (final category in categories) {
      final itemExists = category.menu.any(
        (categoryItem) => categoryItem.id == item.id,
      );

      if (!itemExists) {
        continue;
      }

      final categoryImageUrl = category.imageUrl ?? '';

      if (categoryImageUrl.trim().isNotEmpty) {
        return categoryImageUrl;
      }

      final categoryImage = category.image ?? '';

      if (categoryImage.trim().isNotEmpty) {
        return categoryImage;
      }

      break;
    }

    return '';
  }

  List<Menu> _filterItems(List<Menu> items) {
    final query = widget.searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return items;
    }

    return items.where((item) {
      final name = item.name.toLowerCase();
      final description = item.description?.toLowerCase() ?? "";

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Widget _buildSkeletonList() {
    return SizedBox(
      height: 450,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: 4,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          return SizedBox(
            width: 220,
            child: Skeletonizer(
              enabled: true,
              child: FoodCard(
                imageUrl: "",
                name: "Delicious Food Item",
                price: "999",
                description: "This is a delicious food item description",
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addSimpleItemToCart({
    required Menu item,
    required double selectedPrice,
    required double deliveryPrice,
    required double takeAwayPrice,
    required OrderType orderType,
  }) async {
    if (_addingItemId != null) {
      return;
    }

    setState(() {
      _addingItemId = item.id;
    });

    final newCartItem = CartItem(
      menuId: item.id,
      name: item.name,
      quantity: 1,
      selectedPrice: selectedPrice,
      deliveryPrice: deliveryPrice,
      takeAwayPrice: takeAwayPrice,
      orderType: orderType == OrderType.delivery ? "delivery" : "takeaway",
      imageUrl: item.imageUrl ?? "",
    );

    try {
      await context.read<CartProvider>().addToCart(newCartItem);

      if (!mounted) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 450));

      if (!mounted) {
        return;
      }

      setState(() {
        _addingItemId = null;
      });

      _showAddedToCartSnackBar(itemName: item.name);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _addingItemId = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to add item to cart',
              style: AppTextStyles.body,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _buildFoodCardWithAddEffect({
    required Menu item,
    required String imageUrl,
    required String price,
    required List<RestaurantBranchMenu> categories,
  }) {
    final isAdding = _addingItemId == item.id;

    return Stack(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isAdding ? 0.45 : 1.0,
          child: FoodCard(
            imageUrl: imageUrl,
            name: item.name,
            price: price,
            description: item.description,
          ),
        ),
        if (isAdding)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isAdding ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Adding...', style: AppTextStyles.action),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    if (provider.isLoading) {
      return _buildSkeletonList();
    }

    if (categories.isEmpty) {
      return const SizedBox();
    }

    final allEntries = _buildMenuEntries(categories);
    final filteredEntries = _filterMenuEntries(allEntries);

    if (filteredEntries.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: Colors.white54,
                size: 35,
              ),
              const SizedBox(height: 10),
              Text(
                'No items found for "${widget.searchQuery}"',
                style: AppTextStyles.subtitle.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 450,
      child: ScrollablePositionedList.separated(
        scrollDirection: Axis.horizontal,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: filteredEntries.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final entry = filteredEntries[index];
          final item = entry.item;

          final menuProvider = context.read<MenuProvider>();

          final deliveryPrice = double.tryParse(item.deliveryPrice ?? "0") ?? 0;

          final takeAwayPrice = double.tryParse(item.takeAwayPrice ?? "0") ?? 0;

          final orderType = menuProvider.selectedOrderType;

          final selectedPrice = orderType == OrderType.delivery
              ? deliveryPrice
              : takeAwayPrice;
          final isNotSelectable = selectedPrice <= 0;

          final notSelectableReason = orderType == OrderType.delivery
              ? 'This item is not available for delivery'
              : 'This item is not available for takeaway';

          final cartItem = _getCartItem(cartProvider, item.id);

          final isAddedToCart = cartItem != null;

          final cartQuantity = cartItem?.quantity ?? 0;

          if (isAddedToCart && cartQuantity < 0) {
            return const SizedBox();
          }

          final hasVariations =
              item.menuVariations != null && item.menuVariations!.isNotEmpty;

          final hasChoices = item.choiceGroup.isNotEmpty;

          final isDeal = item.isDeal == true;

          return SizedBox(
            width: 220,
            child: GestureDetector(
              onTap: () async {
                if (isNotSelectable) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          notSelectableReason,
                          style: AppTextStyles.body,
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  return;
                }

                if (isDeal) {
                  widget.onDealTap(item);
                  return;
                }

                if (hasVariations || hasChoices) {
                  widget.onProductTap(item);
                  return;
                }

                await _addSimpleItemToCart(
                  item: item,
                  selectedPrice: selectedPrice,
                  deliveryPrice: deliveryPrice,
                  takeAwayPrice: takeAwayPrice,
                  orderType: orderType,
                );
              },
              child: Opacity(
                opacity: isNotSelectable ? 0.45 : 1.0,
                child: _buildFoodCardWithAddEffect(
                  item: item,
                  imageUrl: _getItemImage(item, categories),
                  price: selectedPrice.toStringAsFixed(0),
                  categories: categories,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddedToCartSnackBar({required String itemName}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$itemName added to cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
