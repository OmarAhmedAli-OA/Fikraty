import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent
  static const Color primary = Color(0xFF5548E8); // Purple / Indigo
  static const Color primaryLight = Color(0xFF7C6FF7); // Light Indigo
  static const Color secondary = Color(0xFF00C48C); // Teal / Emerald Accent
  static const Color secondaryDark = Color(0xFF00A876); // Dark Teal

  // Neutral & Surfaces
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color background = Color(0xFFF7F7FB); // Light Gray-Lavender
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEAEAEF); // Border Gray
  static const Color divider = Color(0xFFF0F0F6); // Subtle Divider
  static const Color inputHint = Color(0xFFA0A0C0);
  static const Color track = Color(0xFFE0E0EC);

  // Typography
  static const Color darkText = Color(0xFF0C0C14); // Charcoal / Main Heading
  static const Color mutedText = Color(0xFF5050A0); // Soft Slate Purple
  static const Color tertiaryText = Color(0xFF8080A0); // Gray Purple
  static const Color subtleText = Color(0xFF6060A0); // Subtle Purple
  static const Color chipText = Color(0xFF404060);

  // States & Badges
  static const Color selectionTint = Color(0xFFEEF0FF); // Light Purple Active Tint
  static const Color primaryTint = Color(0xFFEDE9FE); // Soft Purple Tint / Pending Badges
  static const Color secondaryTint = Color(0xFFCCFBF1); // Soft Teal Tint
  static const Color secondarySoft = Color(0xFFE6FFFA); // Very Light Teal
  static const Color error = Color(0xFFEF4444); // Red Error
  static const Color errorLight = Color(0xFFFFEBEE); // Soft Red Tint
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color warningLight = Color(0xFFFEF3C7); // Soft Amber Tint
  static const Color success = Color(0xFF10B981); // Emerald / Success
  static const Color successLight = Color(0xFFE8F5E9); // Soft Emerald Tint

  // Specific Feature Badges
  static const Color badgePitcherBg = Color(0xFFFEF3C7);
  static const Color badgePitcherText = Color(0xFFD97706);
  static const Color badgeGrowingBg = Color(0xFFCCFBF1);
  static const Color badgeGrowingText = Color(0xFF0F766E);
  static const Color badgeReviewBg = Color(0xFFEDE9FE);
  static const Color badgeReviewText = Color(0xFF6D28D9);

  // Additional Neutral & Helpers
  static const Color borderLight = Color(0xFFF1F2F6);
  static const Color textSecondary = Color(0xFF6B7280); // Secondary Body Text
  static const Color textMuted = Color(0xFF9CA3AF); // Muted / Placeholder Text

  // Social
  static const Color googleRed = Color(0xFFEA4335);
  static const Color linkedInBlue = Color(0xFF0A66C2);

  // Common
  static const Color white = Colors.white;
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Backward compatibility aliases
  static const Color navy = primary;
  static const Color blue = secondary;
  static const Color tint = selectionTint;
  static const Color lightSurface = background;
  static const Color ink = darkText;
  static const Color accent = primaryLight;
}
