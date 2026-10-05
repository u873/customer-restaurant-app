import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:customer_estaurant_app/features/auth/controller/auth_controller.dart';
import 'package:customer_estaurant_app/features/branch/controller/branch_controller.dart';
import 'package:customer_estaurant_app/features/menu/controller/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final minimumSplashTime = Future.delayed(const Duration(seconds: 3));

      final branchController = context.read<BranchController>();

      final menuProvider = context.read<MenuProvider>();

      final authController = context.read<AuthController>();
      await branchController.getBranches();
      if (branchController.selectedBranch != null) {
        await menuProvider.getMenu(branchController.selectedBranch!.id, 1);
      }
      while (authController.isSessionLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await minimumSplashTime;

      if (!mounted) return;
      widget.onFinished();
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
