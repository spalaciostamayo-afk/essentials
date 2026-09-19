import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: AppSizes.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLarge,
        ),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );
}