import 'package:customer_estaurant_app/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../features/cart/controller/cart_controller.dart';

class HomeBottomNav extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onCartTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onProfileTap;

  final int selectedIndex;

  const HomeBottomNav({
    super.key,
    required this.onHomeTap,
    required this.onCartTap,
    required this.onHistoryTap,
    required this.onProfileTap,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final cartProvider = context.watch<CartProvider>();

    // Cart mein total items ki quantity.
    int cartItemCount = 0;

    for (final item in cartProvider.cartItems) {
      cartItemCount += item.quantity;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  selected: selectedIndex == 0,
                  onTap: onHomeTap,
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  selected: selectedIndex == 1,
                  onTap: onCartTap,
                  badgeCount: cartItemCount,
                ),
              ),

              if (auth.isLoggedIn)
                Expanded(
                  child: _NavItem(
                    icon: Icons.history_outlined,
                    selected: selectedIndex == 2,
                    onTap: onHistoryTap,
                  ),
                ),

              Expanded(
                child: auth.isSessionLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : _NavItem(
                        icon: Icons.person,
                        selected: selectedIndex == 3,
                        onTap: onProfileTap,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 23, color: Colors.white),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: selected ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),

            // Cart badge
            if (badgeCount > 0)
              Positioned(
                top: 2,
                right: 24,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
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
