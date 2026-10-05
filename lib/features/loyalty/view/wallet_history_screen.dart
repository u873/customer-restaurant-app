import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../loyalty/provider/loyalty_provider.dart';

class WalletHistoryScreen extends StatefulWidget {
  final VoidCallback onClose;

  const WalletHistoryScreen({super.key, required this.onClose});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadWalletData();
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
                      width: 36,
                      height: 36,
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
                      child: Text("Wallet", style: AppTextStyles.title),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            Expanded(
              child: Consumer<LoyaltyProvider>(
                builder: (context, wallet, child) {
                  if (wallet.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (wallet.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          wallet.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.cardBackground,
                    onRefresh: wallet.loadWalletData,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      children: [
                        _WalletBalanceCard(amount: wallet.walletAmount),
                        const SizedBox(height: 28),
                        Text("Wallet History", style: AppTextStyles.title),
                        const SizedBox(height: 12),
                        if (wallet.walletTransactions.isEmpty)
                          const _EmptyWalletHistory()
                        else
                          ...wallet.walletTransactions.map((transaction) {
                            return _WalletTransactionCard(
                              transaction: transaction,
                            );
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

class _WalletBalanceCard extends StatelessWidget {
  final double amount;

  const _WalletBalanceCard({required this.amount});

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
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available Balance", style: AppTextStyles.subtitle),
              const SizedBox(height: 5),
              Text(
                "Rs. ${amount.toStringAsFixed(0)}",
                style: AppTextStyles.largeValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyWalletHistory extends StatelessWidget {
  const _EmptyWalletHistory();

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
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.iconSecondary,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            "No wallet transactions yet",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _WalletTransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _WalletTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
