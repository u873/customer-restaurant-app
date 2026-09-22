import 'package:customer_estaurant_app/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16,16,),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                selected: selectedIndex == 0,
                onTap: onHomeTap,
              ),

              _NavItem(
                icon: Icons.shopping_cart_outlined,
                selected: selectedIndex == 1,
                onTap: onCartTap,
              ),

              _NavItem(
                icon: Icons.history_outlined,
                selected: selectedIndex == 2,
                onTap: onHistoryTap,
              ),

              if (auth.isSessionLoading)
                const SizedBox(
                  width: 45,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                _NavItem(
                  icon: Icons.person,
                  selected: selectedIndex == 3,
                  onTap: onProfileTap,
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

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        width: 45,
        height: 48,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: Colors.white,
            ),

            const SizedBox(height: 2),

            AnimatedContainer(
              duration: const Duration(
                milliseconds: 300,
              ),
              width: selected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}