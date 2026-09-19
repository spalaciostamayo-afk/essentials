import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  static const TextStyle value = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}