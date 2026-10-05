import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view/cart_screen.dart';
import '../controller/cart_controller.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    if (cartProvider.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xffF6C400),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
              const CartScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xffF6C400),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'View Cart',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),

                  Text(
                    'Rs ${cartProvider.subtotal.toStringAsFixed(0)}',
                    style: AppTextStyles.price.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(width: 6),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}