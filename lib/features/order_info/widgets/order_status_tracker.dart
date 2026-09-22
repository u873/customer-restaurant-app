import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OrderStatus extends StatelessWidget {
  const OrderStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [const StatusDot(active: true,),
            const StatusLine(),
            const StatusDot(active: true,),
            const StatusLine(),
            const StatusDot(active: false,),
            const StatusLine(),
            const StatusDot(active: false,),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          "Preparing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class StatusDot extends StatelessWidget {
  final bool active;

  const StatusDot({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.primary
            : Colors.white54,
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  const StatusLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: 45,
          height: 4,
          color: Colors.white38,
        ),
    );
  }
}