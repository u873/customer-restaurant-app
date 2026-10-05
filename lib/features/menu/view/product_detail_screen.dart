import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/model/cart_item.dart';
import '../controller/menu_controller.dart';
import '../model/main_data_response.dart';

class ProductDetailScreen extends StatefulWidget {
  final Menu item;
  final VoidCallback onClose;
  final VoidCallback? onAddedToCart;

  const ProductDetailScreen({
    super.key,
    required this.item,
    required this.onClose,
    this.onAddedToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int selectedVariationIndex = 0;

  final Map<int, List<CartChoice>> selectedChoicesByGroup = {};

  Menu get item => widget.item;

  List<MenuVariation> get variations => item.menuVariations ?? [];

  MenuVariation? get selectedVariation {
    if (variations.isEmpty) return null;

    if (selectedVariationIndex >= variations.length) {
      return variations.first;
    }

    return variations[selectedVariationIndex];
  }

  List<ChoiceGroup> get currentChoiceGroups {
    if (selectedVariation != null) {
      return selectedVariation!.choiceGroups ?? [];
    }

    return item.choiceGroup ?? [];
  }

  double _price(String? value, [String? fallback]) {
    return double.tryParse(value ?? '') ?? double.tryParse(fallback ?? '') ?? 0;
  }

  double _activePrice(
    String? price,
    String? deliveryPrice,
    String? takeAwayPrice,
    OrderType orderType,
  ) {
    if (orderType == OrderType.delivery) {
      return _price(deliveryPrice, price);
    }

    return _price(takeAwayPrice, price);
  }

  double _selectedChoicesTotal(OrderType orderType) {
    double total = 0;

    for (final choices in selectedChoicesByGroup.values) {
      for (final choice in choices) {
        total += orderType == OrderType.delivery
            ? choice.deliveryPrice
            : choice.takeAwayPrice;
      }
    }

    return total;
  }

  void _updateGroupChoices(ChoiceGroup group, List<CartChoice> choices) {
    setState(() {
      if (choices.isEmpty) {
        selectedChoicesByGroup.remove(group.id);
      } else {
        selectedChoicesByGroup[group.id] = choices;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final orderType = menuProvider.selectedOrderType;

    final variation = selectedVariation;

    final itemPrice = _activePrice(
      variation?.price ?? item.price,
      variation?.deliveryPrice ?? item.deliveryPrice,
      variation?.takeAwayPrice ?? item.takeAwayPrice,
      orderType,
    );

    final choicesTotal = _selectedChoicesTotal(orderType);

    final totalPrice = (itemPrice + choicesTotal) * quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          _CircleButton(
                            icon: Icons.arrow_back_ios_new,
                            onTap: widget.onClose,
                            // onTap: () {
                            //    Navigator.pop(context);
                            // },
                          ),
                          Expanded(
                            child: Text(
                              item.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 42),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          child: Icon(
                            Icons.star,
                            color: AppColors.rating,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 275,
                      width: double.infinity,
                      child: Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 80,
                                    color: AppColors.textTertiary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Description",
                                  style: AppTextStyles.title.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _QuantityControl(
                                quantity: quantity,
                                onMinus: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                onPlus: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.description?.isNotEmpty == true
                                ? item.description!
                                : "Enjoy our delicious food prepared with fresh ingredients and amazing flavor.",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySecondary.copyWith(
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (variations.isNotEmpty) ...[
                            Text(
                              "Choose Variation",
                              style: AppTextStyles.price.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _VariationSelector(
                              variations: variations,
                              selectedIndex: selectedVariationIndex,
                              onChanged: (index) {
                                setState(() {
                                  selectedVariationIndex = index;
                                  selectedChoicesByGroup.clear();
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (currentChoiceGroups.isNotEmpty) ...[
                            Text(
                              "Choices",
                              style: AppTextStyles.price.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...currentChoiceGroups.map(
                              (group) => _ChoiceGroupCard(
                                group: group,
                                selectedChoices:
                                    selectedChoicesByGroup[group.id] ?? [],
                                onChanged: (choices) {
                                  _updateGroupChoices(group, choices);
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
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
                            Text(
                              "Price",
                              style: AppTextStyles.small.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              "Rs ${totalPrice.toStringAsFixed(2)}",
                              style: AppTextStyles.price.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addToCart,
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Add To Cart",
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
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
      ),
    );
  }

  void _addToCart() {
    final groups = currentChoiceGroups;

    for (final group in groups) {
      final selected = selectedChoicesByGroup[group.id]?.length ?? 0;

      if (selected < group.minChoices) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please select at least "
              "${group.minChoices} option(s) "
              "from ${group.name}",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        );
        return;
      }
    }

    final variation = selectedVariation;
    final menuProvider = context.read<MenuProvider>();
    final orderType = menuProvider.selectedOrderType;

    final deliveryPrice = _activePrice(
      variation?.price ?? item.price,
      variation?.deliveryPrice ?? item.deliveryPrice,
      variation?.takeAwayPrice ?? item.takeAwayPrice,
      OrderType.delivery,
    );

    final takeAwayPrice = _activePrice(
      variation?.price ?? item.price,
      variation?.deliveryPrice ?? item.deliveryPrice,
      variation?.takeAwayPrice ?? item.takeAwayPrice,
      OrderType.pickup,
    );

    final selectedPrice = orderType == OrderType.delivery
        ? deliveryPrice
        : takeAwayPrice;

    final allSelectedChoices = selectedChoicesByGroup.values
        .expand((choices) => choices)
        .toList();

    final choicesTotal = _selectedChoicesTotal(orderType);

    final cartItem = CartItem(
      menuId: item.id,
      name: item.name,
      quantity: quantity,
      selectedPrice: selectedPrice,
      deliveryPrice: deliveryPrice,
      takeAwayPrice: takeAwayPrice,
      orderType: orderType == OrderType.delivery ? "delivery" : "takeaway",
      imageUrl: item.imageUrl,
      menuVariationId: variation?.id,
      menuVariationName: variation?.name,
      selectedChoices: allSelectedChoices,
    );

    context.read<CartProvider>().addToCart(cartItem);
    if (widget.onAddedToCart != null) {
      widget.onAddedToCart!();
    } else {
      widget.onClose();
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textSecondary),
        ),
        child: Icon(icon, color: AppColors.iconPrimary, size: 16),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QuantityControl({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMinus,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            icon: const Icon(Icons.remove, color: Colors.white, size: 14),
          ),
          Text(
            "$quantity",
            style: AppTextStyles.bodySecondary.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: onPlus,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            icon: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

class _VariationSelector extends StatelessWidget {
  final List<MenuVariation> variations;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _VariationSelector({
    required this.variations,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.categoryUnselected,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(variations.length, (index) {
          final variation = variations[index];
          final selected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      variation.name,
                      style: AppTextStyles.small.copyWith(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Rs ${variation.price}",
                      style: AppTextStyles.small.copyWith(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ChoiceGroupCard extends StatelessWidget {
  final ChoiceGroup group;
  final List<CartChoice> selectedChoices;
  final ValueChanged<List<CartChoice>> onChanged;

  const _ChoiceGroupCard({
    required this.group,
    required this.selectedChoices,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Select ${group.minChoices} to ${group.maxChoices}",
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...List.generate(group.choices.length, (index) {
            final choice = group.choices[index];

            final isSelected = selectedChoices.any(
              (selected) => selected.id == choice.id,
            );

            return GestureDetector(
              onTap: () {
                final updatedChoices = List<CartChoice>.from(selectedChoices);

                if (isSelected) {
                  updatedChoices.removeWhere(
                    (selected) => selected.id == choice.id,
                  );
                } else {
                  if (updatedChoices.length >= group.maxChoices) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You can select maximum "
                          "${group.maxChoices} option(s) "
                          "from ${group.name}",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  updatedChoices.add(
                    CartChoice(
                      id: choice.id,
                      groupId: group.id,
                      name: choice.name,
                      price: double.tryParse(choice.price ?? "0") ?? 0,
                      takeAwayPrice:
                          double.tryParse(choice.takeAwayPrice ?? "0") ?? 0,
                      deliveryPrice:
                          double.tryParse(choice.deliveryPrice ?? "0") ?? 0,
                    ),
                  );
                }

                onChanged(updatedChoices);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        choice.name,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      "Rs ${choice.price}",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
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
}