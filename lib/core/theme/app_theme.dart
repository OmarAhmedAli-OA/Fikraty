import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightSurface,

  colorScheme: const ColorScheme.light(
    primary: AppColors.navy,
    secondary: AppColors.blue,
    surface: AppColors.lightSurface,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.ink,
  ),

  cardColor: AppColors.tint,

  textTheme: const TextTheme(
    headlineLarge: AppTextStyles.lightHeadline,
    titleLarge: AppTextStyles.lightTitle,
    bodyMedium: AppTextStyles.lightBody,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    secondary: AppColors.blue,
    surface: AppColors.darkSurface,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.darkText,
  ),

  textTheme: const TextTheme(
    headlineLarge: AppTextStyles.darkHeadline,
    titleLarge: AppTextStyles.darkTitle,
    bodyMedium: AppTextStyles.darkBody,
  ),
);
