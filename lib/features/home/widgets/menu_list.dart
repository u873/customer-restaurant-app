import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../cart/controller/cart_controller.dart';
import '../../cart/model/cart_item.dart';
import '../../menu/controller/menu_controller.dart';
import '../../menu/model/main_data_response.dart';
import '../../../core/widgets/food_card.dart';

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

class MenuListState extends State<MenuList> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isScrollingFromCategory = false;

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

  void scrollToCategory(int categoryIndex) {
    if (widget.isSearching || widget.searchQuery.trim().isNotEmpty) {
      return;
    }

    final provider = context.read<MenuProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    // Menu loading ke waqt category scroll nahi karna
    if (provider.isLoading) {
      return;
    }

    if (categories.isEmpty) {
      return;
    }

    if (categoryIndex == 0) {
      if (_itemScrollController.isAttached) {
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
      }

      return;
    }

    final actualCategoryIndex = categoryIndex - 1;

    if (actualCategoryIndex < 0 || actualCategoryIndex >= categories.length) {
      return;
    }

    int firstItemIndex = 0;

    for (int i = 0; i < actualCategoryIndex; i++) {
      firstItemIndex += categories[i].menu.length;
    }

    if (!_itemScrollController.isAttached) {
      return;
    }

    _isScrollingFromCategory = true;

    _itemScrollController
        .scrollTo(
          index: firstItemIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          _isScrollingFromCategory = false;
        });
  }

  void _onItemsChanged() {
    if (widget.isSearching || widget.searchQuery.trim().isNotEmpty) {
      return;
    }

    if (_isScrollingFromCategory) {
      return;
    }

    final provider = context.read<MenuProvider>();

    // Loading ke waqt category calculation nahi karni
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

    int runningItemCount = 0;

    for (int i = 0; i < categories.length; i++) {
      final categoryItemCount = categories[i].menu.length;

      final categoryStart = runningItemCount;

      final categoryEnd = runningItemCount + categoryItemCount - 1;

      if (currentItemIndex >= categoryStart &&
          currentItemIndex <= categoryEnd) {
        final newCategoryIndex = i + 1;

        if (newCategoryIndex != widget.selectedCategoryIndex) {
          widget.onCategoryChanged(newCategoryIndex);
        }

        break;
      }

      runningItemCount += categoryItemCount;
    }
  }

  CartItem? _getCartItem(CartProvider cartProvider, int menuId) {
    for (final cartItem in cartProvider.cartItems) {
      if (cartItem.menuId == menuId) {
        return cartItem;
      }
    }

    return null;
  }

  String _getItemImage(Menu item, List<RestaurantBranchMenu> categories) {
    // 1. Item ki image
    final itemImageUrl = item.imageUrl ?? '';

    if (itemImageUrl.trim().isNotEmpty) {
      return itemImageUrl;
    }

    final itemImage = item.image ?? '';

    if (itemImage.trim().isNotEmpty) {
      return itemImage;
    }

    // 2. Category ki image
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

    // 3. Koi image nahi
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

    final allItems = categories.expand((category) => category.menu).toList();
    final filteredItems = _filterItems(allItems);

    if (filteredItems.isEmpty) {
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
                "No items found for \"${widget.searchQuery}\"",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
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

        itemCount: filteredItems.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },

        itemBuilder: (context, index) {
          final item = filteredItems[index];

          final menuProvider = context.read<MenuProvider>();

          final deliveryPrice = double.tryParse(item.deliveryPrice ?? "0") ?? 0;

          final takeAwayPrice = double.tryParse(item.takeAwayPrice ?? "0") ?? 0;

          final orderType = menuProvider.selectedOrderType;

          final selectedPrice = orderType == OrderType.delivery
              ? deliveryPrice
              : takeAwayPrice;

          final cartItem = _getCartItem(cartProvider, item.id);
          final isAddedToCart = cartItem != null;
          final cartQuantity = cartItem?.quantity ?? 0;

          if (isAddedToCart && cartQuantity < 0) {
            return const SizedBox();
          }

          return SizedBox(
            width: 220,
            child: GestureDetector(
              onTap: () async {
                if (item.isDeal == true) {
                  widget.onDealTap(item);
                  return;
                }

                final hasVariations =
                    item.menuVariations != null &&
                    item.menuVariations!.isNotEmpty;

                final hasChoices = item.choiceGroup.isNotEmpty;

                if (hasVariations || hasChoices) {
                  widget.onProductTap(item);
                  return;
                }

                final newCartItem = CartItem(
                  menuId: item.id,
                  name: item.name,
                  quantity: 1,
                  selectedPrice: selectedPrice,
                  deliveryPrice: deliveryPrice,
                  takeAwayPrice: takeAwayPrice,
                  orderType: orderType == OrderType.delivery
                      ? "delivery"
                      : "takeaway",
                  imageUrl: item.imageUrl ?? "",
                );

                await context.read<CartProvider>().addToCart(newCartItem);

                if (!mounted) {
                  return;
                }

                _showAddedToCartSnackBar(itemName: item.name);
              },

              child: FoodCard(
                imageUrl: _getItemImage(item, categories),
                name: item.name,
                price: selectedPrice.toStringAsFixed(0),
                description: item.description,
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
