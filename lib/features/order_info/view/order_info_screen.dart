import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../order_history/model/order_history_model.dart';

class OrderInfoScreen extends StatelessWidget {
  final String orderNumber;
  final List<dynamic> orderItems;
  final OrderHistory? order;
  final VoidCallback onClose;
  final VoidCallback? onTrackOrder;

  const OrderInfoScreen({
    super.key,
    required this.orderNumber,
    required this.orderItems,
    this.order,
    required this.onClose,
    this.onTrackOrder,
  });

  // String _formatDate(DateTime? date) {
  //   if (date == null) return '';
  //
  //   final hour = date.hour > 12
  //       ? date.hour - 12
  //       : date.hour == 0
  //       ? 12
  //       : date.hour;
  //
  //   final minute = date.minute.toString().padLeft(2, '0');
  //
  //   final period = date.hour >= 12 ? 'PM' : 'AM';
  //
  //   return '${date.day.toString().padLeft(2, '0')}/'
  //       '${date.month.toString().padLeft(2, '0')}/'
  //       '${date.year} $hour:$minute $period';
  // }

  bool _canTrackOrder(OrderHistory order) {
    final orderType = order.orderType.type.trim().toLowerCase();
    final status = order.orderStatus.name.trim().toLowerCase();

    return orderType == 'delivery' && status == 'out for delivery';
  }

  @override
  Widget build(BuildContext context) {
    final historyOrder = order;

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
                    onTap: onClose,
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
                      child: Text("Order Info", style: AppTextStyles.title),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            // const SizedBox(height: 5),
            // Text("Order Number", style: AppTextStyles.bodySecondary),
            // const SizedBox(height: 4),
            // Text(
            //   orderNumber,
            //   style: AppTextStyles.largeValue.copyWith(fontSize: 21),
            // ),
            // if (historyOrder != null) ...[
            //   const SizedBox(height: 5),
            //   Text(
            //     _formatDate(historyOrder.orderDate),
            //     style: AppTextStyles.small,
            //   ),
            // ],
              SizedBox(height: 18),
            if (historyOrder != null) ...[
              _OrderStatusTimeline(status: historyOrder.orderStatus.name),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.foodCardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoColumn(
                          title: "Order Type",
                          value: historyOrder.orderType.type,
                        ),
                      ),
                      Expanded(
                        child: _InfoColumn(
                          title: "Payment",
                          value: historyOrder.paymentType.type,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 15),
            if (historyOrder != null &&
                onTrackOrder != null &&
                _canTrackOrder(historyOrder))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onTrackOrder,
                    icon: const Icon(Icons.location_on_outlined, size: 20),
                    label: Text('Track Order', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            if (historyOrder != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Items Ordered", style: AppTextStyles.title),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: historyOrder == null
                  ? Center(
                      child: Text(
                        "No order details",
                        style: AppTextStyles.bodySecondary,
                      ),
                    )
                  : historyOrder.orderDetails.isEmpty
                  ? Center(
                      child: Text(
                        "No items",
                        style: AppTextStyles.bodySecondary,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: historyOrder.orderDetails.length,
                      itemBuilder: (context, index) {
                        final item = historyOrder.orderDetails[index];

                        return _OrderDetailCard(item: item);
                      },
                    ),
            ),
            if (historyOrder != null) _OrderSummary(order: historyOrder),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({required this.title, required this.value});

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
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  final OrderDetail item;

  const _OrderDetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fastfood_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Qty: ${item.quantity.toStringAsFixed(0)}",
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              Text(
                "Rs. ${item.price.toStringAsFixed(0)}",
                style: AppTextStyles.price,
              ),
            ],
          ),
          if (item.menuVariation != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Variation: ${item.menuVariation!.name}",
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ],
          if (item.choices.isNotEmpty) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choices: ${item.choices.map((e) => e.choiceName).join(', ')}",
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ],
          if (item.dealDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deal Items",
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...item.dealDetails.map(
              (deal) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "• ${deal.menuName}",
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final OrderHistory order;

  const _OrderSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _SummaryRow(title: "Subtotal", value: order.subTotal),
          if (order.deliveryCharge > 0)
            _SummaryRow(title: "Delivery Charges", value: order.deliveryCharge),
          if (order.taxAmount > 0)
            _TaxRow(taxAmount: order.taxAmount, isIncluded: order.taxInclude),
          if (order.walletAmount > 0)
            _SummaryRow(title: "Wallet", value: -order.walletAmount),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                "Total",
                style: AppTextStyles.price.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "Rs. ${order.total.toStringAsFixed(0)}",
                style: AppTextStyles.price.copyWith(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final double value;

  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.small),
          const Spacer(),
          Text(
            "${value < 0 ? '-' : ''} Rs. ${value.abs().toStringAsFixed(0)}",
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final double taxAmount;
  final bool isIncluded;

  const _TaxRow({required this.taxAmount, required this.isIncluded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            isIncluded ? "Tax (Included)" : "Tax",
            style: AppTextStyles.small,
          ),
          const Spacer(),
          Text(
            "Rs. ${taxAmount.toStringAsFixed(0)}",
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class _OrderStatusTimeline extends StatelessWidget {
  final String status;

  const _OrderStatusTimeline({required this.status});

  int _getCurrentStep() {
    final value = status.trim().toLowerCase();

    if (value == 'received' || value == 'pending') {
      return 0;
    }

    if (value == 'preparing') {
      return 1;
    }

    if (value == 'ready') {
      return 2;
    }

    if (value == 'out for delivery') {
      return 3;
    }

    if (value == 'delivered') {
      return 4;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep();

    const steps = [
      'Received',
      'Preparing',
      'Ready',
      'Out for Delivery',
      'Delivered',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.foodCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS TITLE
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // CIRCLES + CONNECTING LINE
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 18,
                  right: 18,
                  top: 16,
                  child: Container(height: 3, color: AppColors.border),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(steps.length, (index) {
                    final isCompleted = index <= currentStep;

                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // LABELS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
