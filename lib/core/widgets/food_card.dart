import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FoodCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String? description;

  const FoodCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 400,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // CARD
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Container(
              height: 240,
              padding: const EdgeInsets.fromLTRB(
                10,
                120,
                10,
                10,
              ),
              decoration: BoxDecoration(
                color: AppColors.foodCardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(78),
                  topRight: Radius.circular(78),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // RATING
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 15,
                      ),
                      Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 15,
                      ),
                      Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 15,
                      ),
                      Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 15,
                      ),
                      Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 15,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // NAME
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.foodCardText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // PRICE
                  Text(
                    "Rs $price",
                    style: const TextStyle(
                      color: AppColors.foodCardText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // DESCRIPTION
                  if (description != null &&
                      description!.isNotEmpty)
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.foodCardSecondaryText,
                        fontSize: 8,
                        height: 1.2,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // FOOD IMAGE
          Positioned(
            top: 0,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.foodCardBackground,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: AppColors.cardBackground,
                      child: const Icon(
                        Icons.fastfood,
                        color: AppColors.iconSecondary,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}