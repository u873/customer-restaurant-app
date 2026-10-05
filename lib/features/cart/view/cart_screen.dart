import 'package:customer_estaurant_app/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/cart_controller.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onCheckout;

  const CartScreen({super.key, this.onClose, this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,

        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
            onPressed: () {
              if (onClose != null) {
                onClose!();
              }
            },
            style: IconButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: .35)),
              shape: const CircleBorder(),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),

        title: Text(
          "My Cart",
          style: AppTextStyles.title.copyWith(color: AppColors.white),
        ),

        actions: cartProvider.cartItems.isEmpty
            ? null
            : [
                TextButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  child: Text("Clear", style: AppTextStyles.action),
                ),

                const SizedBox(width: 8),
              ],
      ),

      body: cartProvider.cartItems.isEmpty
          ? _EmptyCart(onBrowseMenu: onClose)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];

                final quantity = item.quantity;
                final total = cartProvider.itemTotal(item);
                final price = total / quantity;

                return _CartItemCard(
                  item: item,
                  price: price,
                  quantity: quantity,
                  total: total,
                  onDecrease: () {
                    cartProvider.decreaseQuantity(index);
                  },
                  onIncrease: () {
                    cartProvider.increaseQuantity(index);
                  },
                );
              },
            ),

      bottomNavigationBar: cartProvider.cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 125,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2B2C30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Item Subtotal:",
                                style: AppTextStyles.price.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Rs ${cartProvider.subtotal.toStringAsFixed(2)}",
                                style: AppTextStyles.bodySecondary.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          const Divider(
                            color: AppColors.background,
                            height: 1,
                            thickness: 3,
                          ),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Grand Total:",
                                style: AppTextStyles.title.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Rs ${cartProvider.subtotal.toStringAsFixed(2)}",
                                style: AppTextStyles.price.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthController>();
                          if (!auth.isLoggedIn) {
                            onCheckout?.call();
                            return;
                          }
                          onCheckout?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Checkout",
                          style: AppTextStyles.button.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff292A2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Clear Cart?",
            style: AppTextStyles.dialogTitle.copyWith(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to remove all items from your cart?",
            style: AppTextStyles.dialogContent.copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.action.copyWith(color: Colors.white70),
              ),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await context.read<CartProvider>().clearCart();
              },
              child: Text("Clear Cart", style: AppTextStyles.action),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final dynamic item;
  final double price;
  final int quantity;
  final double total;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.item,
    required this.price,
    required this.quantity,
    required this.total,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  bool _showDetails = false;

  bool get _hasDetails {
    if (widget.item.isDeal) {
      return widget.item.dealItems.isNotEmpty;
    }

    return (widget.item.menuVariationName != null &&
            widget.item.menuVariationName!.trim().isNotEmpty) ||
        widget.item.selectedChoices.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xff292A2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // ================= MAIN ITEM =================
          SizedBox(
            height: 88,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 6),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Image.network(
                        widget.item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(
                            color: const Color(0xff343539),
                            child: const Icon(
                              Icons.fastfood_outlined,
                              size: 24,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          "Rs ${widget.price.toStringAsFixed(2)}",
                          style: AppTextStyles.price.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (_hasDetails)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _showDetails = !_showDetails;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _showDetails ? "Show Less" : "Show More",
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  Icon(
                                    _showDetails
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // SAME ORIGINAL QUANTITY BUTTON
                  _QuantityButton(
                    quantity: widget.quantity,
                    onDecrease: widget.onDecrease,
                    onIncrease: widget.onIncrease,
                  ),
                ],
              ),
            ),
          ),

          // ================= DETAILS =================
          if (_showDetails && _hasDetails)
            Container(
              height: 74,
              margin: const EdgeInsets.fromLTRB(8, 0, 6, 7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff343539),
                borderRadius: BorderRadius.circular(7),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildDetails(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final List<Widget> details = [];

    if (widget.item.isDeal) {
      for (final dealItem in widget.item.dealItems) {
        details.add(_detailRow(Icons.restaurant_menu, dealItem.name));

        if (dealItem.variationName != null &&
            dealItem.variationName!.trim().isNotEmpty) {
          details.add(
            _detailRow(Icons.tune, dealItem.variationName!, subItem: true),
          );
        }

        for (final choice in dealItem.selectedChoices) {
          details.add(
            _detailRow(Icons.check_circle_outline, choice.name, subItem: true),
          );
        }
      }
    } else {
      if (widget.item.menuVariationName != null &&
          widget.item.menuVariationName!.trim().isNotEmpty) {
        details.add(_detailRow(Icons.tune, widget.item.menuVariationName!));
      }

      for (final choice in widget.item.selectedChoices) {
        details.add(
          _detailRow(Icons.check_circle_outline, choice.name, subItem: true),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details,
    );
  }

  Widget _detailRow(IconData icon, String text, {bool subItem = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3, left: subItem ? 8 : 0),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: Colors.white70,
                fontWeight: subItem ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatefulWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityButton({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleIncrease() async {
    // Small press animation
    await _animationController.forward();

    if (!mounted) return;

    widget.onIncrease();

    // Back to normal size
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleIncrease,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              "${widget.quantity}",
              key: ValueKey(widget.quantity),
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDecrease,
            child: const Icon(Icons.remove, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback? onBrowseMenu;

  const _EmptyCart({this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xff292A2D),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              "Your Cart is Empty",
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(color: Colors.white),
            ),

            const SizedBox(height: 8),

            Text(
              "Looks like you haven't added anything to your cart yet.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: Colors.white60,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 180,
              height: 46,
              child: ElevatedButton(
                onPressed: onBrowseMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(
                  "Browse Menu",
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
