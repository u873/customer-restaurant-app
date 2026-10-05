import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../model/loyalty_transaction_model.dart';
import '../model/point_convert_package_model.dart';
import '../provider/loyalty_provider.dart';

class LoyaltyHistoryScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onRedeemPoints;

  const LoyaltyHistoryScreen({
    super.key,
    required this.onClose,
    required this.onRedeemPoints,
  });

  @override
  State<LoyaltyHistoryScreen> createState() => _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends State<LoyaltyHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.iconPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Loyalty Points", style: AppTextStyles.title),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<LoyaltyProvider>(
                builder: (context, loyalty, child) {
                  if (loyalty.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (loyalty.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          loyalty.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.cardBackground,
                    onRefresh: loyalty.loadLoyaltyData,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                      children: [
                        _PointsCard(points: loyalty.loyaltyPoints),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: widget.onRedeemPoints,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.redeem),
                            label: Text(
                              "Redeem Points",
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text("Points History", style: AppTextStyles.title),
                        const SizedBox(height: 12),
                        if (loyalty.loyaltyTransactions.isEmpty)
                          const _EmptyHistory()
                        else
                          ...loyalty.loyaltyTransactions.map((transaction) {
                            return _TransactionCard(transaction: transaction);
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final double points;

  const _PointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available Points", style: AppTextStyles.subtitle),
              const SizedBox(height: 5),
              Text(points.toStringAsFixed(0), style: AppTextStyles.largeValue),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, color: AppColors.iconSecondary, size: 45),
          const SizedBox(height: 12),
          Text(
            "No loyalty transactions yet",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final LoyaltyTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class LoyaltyRedemptionScreen extends StatefulWidget {
  final VoidCallback onClose;

  const LoyaltyRedemptionScreen({super.key, required this.onClose});

  @override
  State<LoyaltyRedemptionScreen> createState() =>
      _LoyaltyRedemptionScreenState();
}

class _LoyaltyRedemptionScreenState extends State<LoyaltyRedemptionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.iconPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Redeem Points", style: AppTextStyles.title),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<LoyaltyProvider>(
                builder: (context, loyalty, child) {
                  if (loyalty.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (loyalty.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          loyalty.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    );
                  }

                  if (loyalty.packages.isEmpty) {
                    return Center(
                      child: Text(
                        "No redemption packages available",
                        style: AppTextStyles.bodySecondary,
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.foodCardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.stars_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Points",
                                  style: AppTextStyles.subtitle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loyalty.loyaltyPoints.toStringAsFixed(0),
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text("Available Packages", style: AppTextStyles.title),
                      const SizedBox(height: 12),
                      ...loyalty.packages.map((package) {
                        return _PackageCard(
                          package: package,
                          currentPoints: loyalty.loyaltyPoints,
                          isRedeeming: loyalty.isRedeeming,
                          onRedeem: () {
                            _redeem(package.loyaltyWalletPackageId);
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redeem(String packageId) async {
    final loyalty = context.read<LoyaltyProvider>();

    final success = await loyalty.redeemPackage(packageId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            "Points converted to wallet successfully.",
            style: AppTextStyles.button,
          ),
        ),
      );

      widget.onClose();
    } else if (loyalty.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardBackground,
          content: Text(
            loyalty.errorMessage!,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }
}

class _PackageCard extends StatelessWidget {
  final PointConvertPackage package;
  final double currentPoints;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  const _PackageCard({
    required this.package,
    required this.currentPoints,
    required this.isRedeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final bool canRedeem = currentPoints >= package.points;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${package.points.toStringAsFixed(0)} Points → Rs. ${package.amount.toStringAsFixed(0)}",
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: canRedeem && !isRedeeming ? onRedeem : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRedeem
                  ? AppColors.primary
                  : AppColors.cardBackgroundLight,
              foregroundColor: canRedeem
                  ? AppColors.textOnPrimary
                  : AppColors.textTertiary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              canRedeem ? "Redeem" : "Not Enough",
              style: AppTextStyles.button.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
