import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.darkText,
    error: AppColors.error,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  ),
  cardColor: AppColors.surface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: AppColors.darkText),
    titleTextStyle: TextStyle(
      color: AppColors.darkText,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: AppTextStyles.lightHeadline,
    titleLarge: AppTextStyles.lightTitle,
    bodyMedium: AppTextStyles.lightBody,
  ),
);

// Alias for convenience across the app
final ThemeData appTheme = lightTheme;
