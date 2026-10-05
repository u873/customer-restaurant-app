import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class OrderItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int quantity;
  final double total;

  const OrderItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xff292A2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // IMAGE
          ClipOval(
            child: Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.fastfood,
                    color: Colors.white54,
                    size: 20,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          // NAME + QUANTITY
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "Quantity: $quantity",
                  style: AppTextStyles.small.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          Text(
            "Rs ${total.toStringAsFixed(2)}",
            style: AppTextStyles.price.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
