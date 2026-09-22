import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/model/cart_item.dart';
import '../controller/menu_controller.dart';
import '../model/main_data_response.dart';

class DealScreen extends StatefulWidget {
  final Menu item;
  final VoidCallback onClose;

  const DealScreen({super.key, required this.item, required this.onClose});

  @override
  State<DealScreen> createState() => _DealScreenState();
}

class _DealScreenState extends State<DealScreen> {
  int quantity = 1;
  Menu get item => widget.item;
  final Map<String, List<MenuVariation>> selectedChoicesByGroup = {};
  String _choiceKey(int menuId, int groupId) {
    return '${menuId}_$groupId';
  }

  List<ChoiceGroup> _getChoiceGroups(Menu detail) {
    final variationGroups = detail.menuVariation?.choiceGroups ?? [];

    final directGroups = detail.choiceGroup;

    return [...variationGroups, ...directGroups];
  }

  CartChoice _createCartChoice(MenuVariation choice, {int? groupId}) {
    final price = double.tryParse(choice.price) ?? 0;

    final deliveryPrice = double.tryParse(choice.deliveryPrice) ?? price;

    final takeAwayPrice = double.tryParse(choice.takeAwayPrice) ?? price;

    return CartChoice(
      id: choice.id,
      groupId: groupId,
      name: choice.name,
      price: price,
      deliveryPrice: deliveryPrice,
      takeAwayPrice: takeAwayPrice,
    );
  }

  double _choicePrice(MenuVariation choice, OrderType orderType) {
    if (orderType == OrderType.delivery) {
      return double.tryParse(choice.deliveryPrice) ??
          double.tryParse(choice.price) ??
          0;
    }

    return double.tryParse(choice.takeAwayPrice) ??
        double.tryParse(choice.price) ??
        0;
  }

  double _variationPrice(MenuVariation variation, OrderType orderType) {
    if (orderType == OrderType.delivery) {
      return double.tryParse(variation.deliveryPrice) ??
          double.tryParse(variation.price) ??
          0;
    }

    return double.tryParse(variation.takeAwayPrice) ??
        double.tryParse(variation.price) ??
        0;
  }

  double _selectedChoicesTotal(OrderType orderType) {
    double total = 0;

    for (final choices in selectedChoicesByGroup.values) {
      for (final choice in choices) {
        total += _choicePrice(choice, orderType);
      }
    }

    return total;
  }

  void _toggleChoice(Menu detail, ChoiceGroup group, MenuVariation choice) {
    final key = _choiceKey(detail.id, group.id);

    setState(() {
      final selectedList = selectedChoicesByGroup[key] ?? [];

      final alreadySelected = selectedList.any(
        (selected) => selected.id == choice.id,
      );

      if (alreadySelected) {
        selectedList.removeWhere((selected) => selected.id == choice.id);
      } else {
        if (selectedList.length >= group.maxChoices) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "You can select maximum "
                "${group.maxChoices} option(s) "
                "from ${group.name}",
              ),
            ),
          );
          return;
        }
        selectedList.add(choice);
      }
      selectedChoicesByGroup[key] = selectedList;
    });
  }

  bool _validateChoices() {
    for (final detail in item.dealMenuDetails ?? []) {
      final groups = _getChoiceGroups(detail);

      for (final group in groups) {
        final key = _choiceKey(detail.id, group.id);

        final selectedCount = selectedChoicesByGroup[key]?.length ?? 0;

        if (selectedCount < group.minChoices) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${detail.name}: Please select "
                "at least ${group.minChoices} "
                "option(s) from ${group.name}",
              ),
            ),
          );

          return false;
        }
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final details = item.dealMenuDetails ?? [];
    final menuProvider = context.watch<MenuProvider>();
    final orderType = menuProvider.selectedOrderType;
    final deliveryPrice = double.tryParse(item.deliveryPrice ?? "0") ?? 0;
    final takeAwayPrice = double.tryParse(item.takeAwayPrice ?? "0") ?? 0;
    final selectedPrice = orderType == OrderType.delivery
        ? deliveryPrice
        : takeAwayPrice;

    final choicesTotal = _selectedChoicesTotal(orderType);
    final totalPrice = (selectedPrice + choicesTotal) * quantity;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),

        title: Text(
          item.name,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: ClipOval(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Image.network(
                          item.imageUrl ?? '',
                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.cardBackground,

                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.white54,
                                size: 60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Rs ${selectedPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Deal Includes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),
                  if (details.isEmpty)
                    const Text(
                      "No items available in this deal.",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    )
                  else
                    ...details.map((detail) {
                      return _buildDealItem(detail, orderType);
                    }),
                  if (choicesTotal > 0) ...[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Selected Extras",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Text(
                            "+ Rs ${choicesTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 6, 16, 16),

            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),

                          Text(
                            "Rs ${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },

                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),

                  Text(
                    "$quantity",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },

                    icon: const Icon(Icons.add, color: Colors.white, size: 17),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await _addToCart(
                        context,
                        selectedPrice,
                        deliveryPrice,
                        takeAwayPrice,
                      );
                    },

                    child: Container(
                      height: 44,

                      margin: const EdgeInsets.only(right: 4),

                      padding: const EdgeInsets.symmetric(horizontal: 18),

                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      alignment: Alignment.center,

                      child: const Text(
                        "Add To Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealItem(Menu detail, OrderType orderType) {
    final groups = _getChoiceGroups(detail);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,

                  child: Image.network(
                    detail.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white54,
                          size: 22,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      "Quantity: ${detail.quantity ?? 1}",

                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),

                    if (detail.menuVariation != null) ...[
                      const SizedBox(height: 3),

                      Text(
                        "Variation: ${detail.menuVariation!.name}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (groups.isNotEmpty) ...[
            const SizedBox(height: 12),

            ...groups.map((group) {
              return _buildChoiceGroup(detail, group, orderType);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceGroup(
    Menu detail,
    ChoiceGroup group,
    OrderType orderType,
  ) {
    final key = _choiceKey(detail.id, group.id);

    final selectedChoices = selectedChoicesByGroup[key] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "${group.minChoices}-${group.maxChoices}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          ...group.choices.map((choice) {
            final selected = selectedChoices.any(
              (selectedChoice) => selectedChoice.id == choice.id,
            );

            final choicePrice = _choicePrice(choice, orderType);

            return GestureDetector(
              onTap: () {
                _toggleChoice(detail, group, choice);
              },

              child: Padding(
                padding: const EdgeInsets.only(bottom: 7),

                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,

                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        choice.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                        ),
                      ),
                    ),

                    Text(
                      choicePrice > 0
                          ? "+ Rs ${choicePrice.toStringAsFixed(2)}"
                          : "Free",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    double selectedPrice,
    double deliveryPrice,
    double takeAwayPrice,
  ) async {
    if (!_validateChoices()) {
      return;
    }

    final menuProvider = context.read<MenuProvider>();

    final orderType = menuProvider.selectedOrderType;

    final List<CartDealItem> cartDealItems = [];
    for (final detail in item.dealMenuDetails ?? []) {
      final detailChoices = <CartChoice>[];
      final groups = _getChoiceGroups(detail);

      for (final group in groups) {
        final key = _choiceKey(detail.id, group.id);

        final choices = selectedChoicesByGroup[key] ?? [];
        detailChoices.addAll(
          choices.map((choice) => _createCartChoice(choice, groupId: group.id)),
        );
      }

      cartDealItems.add(
        CartDealItem(
          id: detail.id,
          menuId: detail.menuId?.toString() ?? '',
          name: detail.name,
          quantity: detail.quantity ?? 1,
          imageUrl: detail.imageUrl ?? '',
          variationId: detail.menuVariation?.id,
          variationName: detail.menuVariation?.name,
          variationPrice: double.tryParse(detail.menuVariation?.price ?? ''),
          selectedChoices: detailChoices,
        ),
      );
    }
  //  final choicesTotal = _selectedChoicesTotal(orderType);
    final cartItem = CartItem(
      menuId: item.id,
      name: item.name,
      quantity: quantity,
      selectedPrice: selectedPrice,
      deliveryPrice: deliveryPrice,
      takeAwayPrice: takeAwayPrice,
      orderType: orderType == OrderType.delivery ? "delivery" : "takeaway",

      imageUrl: item.imageUrl ?? '',
      isDeal: true,
      selectedChoices: const [],
      dealItems: cartDealItems,
    );

    await context.read<CartProvider>().addToCart(cartItem);
    if (!context.mounted) {
      return;
    }
    widget.onClose();
  }
}
