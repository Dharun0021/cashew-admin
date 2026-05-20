import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.trim().toLowerCase()) {
      // Order & Product Statuses
      case 'active':
      case 'paid':
      case 'delivered':
      case 'in stock':
      case 'sent':
      case 'template active':
        backgroundColor = AppColors.successBg;
        textColor = AppColors.success;
        break;

      case 'pending':
      case 'packed':
      case 'shipped':
      case 'low stock':
      case 'unpaid':
        backgroundColor = AppColors.warningBg;
        textColor = AppColors.warning;
        break;

      case 'cancelled':
      case 'inactive':
      case 'out of stock':
      case 'failed':
      case 'refunded':
        backgroundColor = AppColors.errorBg;
        textColor = AppColors.error;
        break;

      default:
        backgroundColor = AppColors.border;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
