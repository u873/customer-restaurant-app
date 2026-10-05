import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Main screen / major section heading
  static const TextStyle heading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // Screen titles, important card titles
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Short subtitle or supporting heading
  static const TextStyle subtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );


  // Normal readable text
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );


  // Descriptions, secondary information
  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  // Helper text, small labels, supporting information
  static const TextStyle small = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  // Buttons throughout the app
  static const TextStyle button = TextStyle(
    color: AppColors.textOnPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // Links, See All, clickable text
  static const TextStyle action = TextStyle(
    color: AppColors.primary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dialogTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dialogContent = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  // Food prices, cart prices, checkout amounts
  static const TextStyle price = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Wallet balance, loyalty points, etc.
  static const TextStyle largeValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );
}
