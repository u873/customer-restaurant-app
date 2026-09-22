import 'package:flutter/material.dart';

import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:customer_estaurant_app/features/order_history/model/order_history_model.dart';
import 'package:customer_estaurant_app/features/order_tracking/view/order_tracking_screen.dart';

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
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Order Info",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Order Number",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              orderNumber,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (historyOrder != null) ...[
              const SizedBox(height: 5),
              Text(
                _formatDate(historyOrder.orderDate),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
            const SizedBox(height: 18),
            if (historyOrder != null)
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
                          title: "Status",
                          value: historyOrder.orderStatus.name,
                        ),
                      ),
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
                    label: const Text(
                      'Track Order',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Items Ordered",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: historyOrder == null
                  ? const Center(
                      child: Text(
                        "No order details",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : historyOrder.orderDetails.isEmpty
                  ? const Center(
                      child: Text(
                        "No items",
                        style: TextStyle(color: AppColors.textSecondary),
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
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Qty: ${item.quantity.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Rs. ${item.price.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (item.menuVariation != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Variation: ${item.menuVariation!.name}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          if (item.choices.isNotEmpty) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choices: ${item.choices.map((e) => e.choiceName).join(', ')}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          if (item.dealDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deal Items",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
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
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
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
              const Text(
                "Total",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "Rs. ${order.total.toStringAsFixed(0)}",
                style: const TextStyle(
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Text(
            "${value < 0 ? '-' : ''} Rs. ${value.abs().toStringAsFixed(0)}",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Text(
            "Rs. ${taxAmount.toStringAsFixed(0)}",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
