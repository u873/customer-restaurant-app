import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:customer_estaurant_app/features/cart/model/cart_item.dart';
import 'package:customer_estaurant_app/features/menu/controller/menu_controller.dart';
import 'package:customer_estaurant_app/features/menu/model/main_data_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/controller/cart_controller.dart';

class SeeAllScreen extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(Menu item, VoidCallback onAddedToCart) onProductTap;
  final ValueChanged<Menu> onDealTap;

  const SeeAllScreen({
    super.key,
    required this.onClose,
    required this.onProductTap,
    required this.onDealTap,
  });

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _selectedCategory = ValueNotifier<int>(0);
  final Map<int, GlobalKey> _categoryKeys = {};

  bool _isCategoryScrolling = false;

  GlobalKey _getCategoryKey(int index) {
    return _categoryKeys.putIfAbsent(index, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  void _onScroll() {
    if (_isCategoryScrolling) return;

    final categories =
        context.read<MenuProvider>().menuResponse?.data.restaurantBranchMenu ??
        [];

    if (categories.isEmpty) return;

    int currentCategory = 0;

    for (int i = 0; i < categories.length; i++) {
      final key = _categoryKeys[i + 1];

      if (key?.currentContext == null) continue;

      final renderObject = key!.currentContext!.findRenderObject();

      if (renderObject is! RenderBox) continue;

      final position = renderObject.localToGlobal(Offset.zero);

      if (position.dy <= 180) {
        currentCategory = i + 1;
      }
    }

    if (_selectedCategory.value != currentCategory) {
      _selectedCategory.value = currentCategory;
    }
  }

  void _onCategorySelected(int index, List<RestaurantBranchMenu> categories) {
    if (_selectedCategory.value == index) return;

    _selectedCategory.value = index;

    if (index == 0) {
      _scrollToTop();
      return;
    }

    final key = _categoryKeys[index];

    if (key?.currentContext == null) return;

    _isCategoryScrolling = true;

    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    ).whenComplete(() {
      _isCategoryScrolling = false;
    });
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _isCategoryScrolling = true;

    _scrollController
        .animateTo(
          0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          _isCategoryScrolling = false;
        });
  }

  String _getItemImage(Menu item, RestaurantBranchMenu category) {
    final itemImageUrl = item.imageUrl ?? '';
    final itemImage = item.image ?? '';

    final categoryImageUrl = category.imageUrl ?? '';
    final categoryImage = category.image ?? '';

    if (itemImageUrl.trim().isNotEmpty) {
      return itemImageUrl;
    }

    if (itemImage.trim().isNotEmpty) {
      return itemImage;
    }

    if (categoryImageUrl.trim().isNotEmpty) {
      return categoryImageUrl;
    }

    if (categoryImage.trim().isNotEmpty) {
      return categoryImage;
    }

    return '';
  }

  Future<void> _addSimpleItemToCart(BuildContext context, Menu item) async {
    final menuProvider = context.read<MenuProvider>();
    final cartProvider = context.read<CartProvider>();

    final bool isDelivery =
        menuProvider.selectedOrderType == OrderType.delivery;

    final double normalPrice = _toDouble(item.price);
    final double deliveryPrice = _toDouble(item.deliveryPrice);
    final double takeAwayPrice = _toDouble(item.takeAwayPrice);

    final double selectedPrice = isDelivery ? deliveryPrice : takeAwayPrice;

    final double finalPrice = selectedPrice > 0 ? selectedPrice : normalPrice;

    final String orderType = isDelivery ? 'delivery' : 'takeaway';

    final cartItem = CartItem(
      menuId: item.id,
      name: item.name,
      quantity: 1,
      selectedPrice: finalPrice,
      deliveryPrice: deliveryPrice > 0 ? deliveryPrice : normalPrice,
      takeAwayPrice: takeAwayPrice > 0 ? takeAwayPrice : normalPrice,
      orderType: orderType,
      imageUrl: item.imageUrl ?? '',
      menuVariationId: null,
      menuVariationName: null,
      isDeal: false,
      selectedChoices: const [],
      dealItems: const [],
    );

    await cartProvider.addToCart(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onItemTap(Menu item) {
    // DEAL
    if (item.isDeal == 1 || item.isDeal == true) {
      widget.onDealTap(item);
      return;
    }

    final bool hasVariations = item.menuVariations?.isNotEmpty ?? false;

    final bool hasChoices = item.choiceGroup.isNotEmpty;

    // ITEM WITH OPTIONS
    if (hasVariations || hasChoices) {
      widget.onProductTap(item, widget.onClose);
      return;
    }

    // SIMPLE ITEM
    _addSimpleItemToCart(context, item);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xff2A2B2F),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, color: Colors.white38, size: 34),
    );
  }

  Widget _buildCategoryBar(List<RestaurantBranchMenu> categories) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedCategory,
      builder: (context, selectedIndex, _) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bool isAll = index == 0;

              final String title = isAll
                  ? 'All types'
                  : categories[index - 1].name;

              final bool selected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  _onCategorySelected(index, categories);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xff242529),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.white10,
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Menu item, RestaurantBranchMenu category) {
    final menuProvider = context.read<MenuProvider>();

    final bool isDelivery =
        menuProvider.selectedOrderType == OrderType.delivery;

    final double normalPrice = _toDouble(item.price);

    final double deliveryPrice = _toDouble(item.deliveryPrice);

    final double takeAwayPrice = _toDouble(item.takeAwayPrice);

    final double price = isDelivery
        ? (deliveryPrice > 0 ? deliveryPrice : normalPrice)
        : (takeAwayPrice > 0 ? takeAwayPrice : normalPrice);

    final String imageUrl = _getItemImage(item, category);

    final bool hasOptions =
        (item.menuVariations?.isNotEmpty ?? false) ||
        item.choiceGroup.isNotEmpty;

    final bool isDeal = item.isDeal == 1 || item.isDeal == true;

    return GestureDetector(
      onTap: () {
        _onItemTap(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xff1F2024),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: 100,
                height: 100,
                child: imageUrl.trim().isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 13),

            // DETAILS
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if ((item.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],

                    const Spacer(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Rs. ${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // PLUS BUTTON
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _onItemTap(item);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isDeal
                                  ? Icons.arrow_forward
                                  : hasOptions
                                  ? Icons.arrow_forward
                                  : Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    int categoryIndex,
    RestaurantBranchMenu category,
  ) {
    if (category.menu.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: _getCategoryKey(categoryIndex + 1),
      margin: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff242529),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${category.menu.length} items',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: category.menu.map((item) {
                return _buildItemCard(item, category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMenu(List<RestaurantBranchMenu> categories) {
    return Column(
      children: [
        for (int i = 0; i < categories.length; i++)
          _buildCategorySection(i, categories[i]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();

    final categories = provider.menuResponse?.data.restaurantBranchMenu ?? [];

    final int totalItems = categories.fold(
      0,
      (sum, category) => sum + category.menu.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xff111214),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff2A2B2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (totalItems > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff242529),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalItems items',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // CATEGORY BAR
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCategoryBar(categories),
              ),

            // MENU
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                  ? const Center(
                      child: Text(
                        'No menu items available',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 30),
                      children: [_buildAllMenu(categories)],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
