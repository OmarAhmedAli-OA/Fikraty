import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle lightHeadline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.ink,
  );

  static const TextStyle lightTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle lightBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.ink,
  );
}
