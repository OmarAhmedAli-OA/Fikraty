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
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: const TextStyle(
      color: AppColors.ink,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.navy,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: 13,
    ),
    prefixIconColor: AppColors.navy,
    suffixIconColor: AppColors.navy,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.navy, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
  ),
);

// Alias for convenience across the app
final ThemeData appTheme = lightTheme;
