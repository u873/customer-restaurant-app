import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/order_history_provider.dart';
import '../model/order_history_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(OrderHistory order) onOrderTap;

  const OrderHistoryScreen({
    super.key,
    required this.onClose,
    required this.onOrderTap,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const int restaurantId = 1248;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryProvider>().loadOrderHistory(
        restaurantId: restaurantId,
      );
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
                      child: Text("Order History", style: AppTextStyles.title),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            Expanded(
              child: Consumer<OrderHistoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    );
                  }

                  if (provider.orders.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          provider.refresh(restaurantId: restaurantId),
                      child: ListView(
                        children: [
                          const SizedBox(height: 180),
                          const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.iconSecondary,
                            size: 55,
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Text(
                              "No orders yet",
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        provider.refresh(restaurantId: restaurantId),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                      itemCount: provider.orders.length,
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];

                        return _OrderHistoryCard(
                          order: order,
                          onTap: () => widget.onOrderTap(order),
                        );
                      },
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

class _OrderHistoryCard extends StatelessWidget {
  final OrderHistory order;
  final VoidCallback onTap;

  const _OrderHistoryCard({required this.order, required this.onTap});

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.foodCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order", style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 3),
                      Text(
                        order.dailyOrderId.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.price.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.iconSecondary,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    title: "Date",
                    value: _formatDate(order.orderDate),
                  ),
                ),
                Expanded(
                  child: _InfoItem(title: "Type", value: order.orderType.type),
                ),
                Expanded(
                  child: _InfoItem(
                    title: "Total",
                    value: "Rs. ${order.total.toStringAsFixed(0)}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text("Status", style: AppTextStyles.bodySecondary),
                const Spacer(),
                Text(
                  order.orderStatus.name,
                  style: AppTextStyles.body.copyWith(
                    color: _statusColor(order.orderStatus.name),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancel':
      case 'cancelled':
        return Colors.red;
      case 'preparing':
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.small),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
