import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent
  static const Color primary = Color(0xFF5548E8); // Purple / Indigo
  static const Color primaryLight = Color(0xFF7C6FF7); // Light Indigo
  static const Color secondary = Color(0xFF00C48C); // Teal / Emerald Accent
  static const Color secondaryDark = Color(0xFF00A876); // Dark Teal

  // Figma Brand & Accent Colors (Home & Chat)
  static const Color primaryPurple = Color(0xFF4F46E5);
  static const Color purpleLight = Color(0xFFEEF2FF);
  static const Color purpleGlow = Color(0xFF6366F1);
  static const Color purpleDark = Color(0xFF3730A3);

  // Badges & Status Colors
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldText = Color(0xFF059669);

  static const Color violetBg = Color(0xFFF5F3FF);
  static const Color violetText = Color(0xFF7C3AED);

  static const Color roseBg = Color(0xFFFEF2F2);
  static const Color roseText = Color(0xFFDC2626);

  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberText = Color(0xFFD97706);

  // UI Neutrals & Borders
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color grayBg = Color(0xFFF8FAFC);

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

  // Social & Channels
  static const Color googleRed = Color(0xFFEA4335);
  static const Color linkedInBlue = Color(0xFF0A66C2);
  static const Color linkedInAlt = Color(0xFF0077B5);
  static const Color whatsAppGreen = Color(0xFF25D366);
  static const Color telegramBlue = Color(0xFF0088CC);
  static const Color instagramPurple = Color(0xFF833AB4);
  static const Color instagramRed = Color(0xFFFD1D1D);
  static const Color instagramYellow = Color(0xFFFBBF24);

  // Extended Semantic & Feature Colors
  static const Color lightIndigoBg = Color(0xFFE0E7FF);
  static const Color indigoText = Color(0xFF4338CA);
  static const Color indigoNavy = Color(0xFF312E81);
  static const Color indigoDarkest = Color(0xFF1E1B4B);
  static const Color pinkBadge = Color(0xFFF43F5E);
  static const Color roseSoft = Color(0xFFFFE4E6);
  static const Color roseActive = Color(0xFFE11D48);
  static const Color activeGreenText = Color(0xFF16A34A);
  static const Color activeGreenBg = Color(0xFFDCFCE7);
  static const Color purpleBadgeText = Color(0xFF9333EA);
  static const Color purpleBadgeBg = Color(0xFFF3E8FF);
  static const Color amberDarkText = Color(0xFFCA8A04);
  static const Color amberLightBg = Color(0xFFFEF9C3);
  static const Color amberSoftBg = Color(0xFFFFF8E6);
  static const Color amberBorder = Color(0xFFFFE0A0);
  static const Color amberDark = Color(0xFFB07000);
  static const Color secondaryFollowingBg = Color(0xFFE6FBF5);
  static const Color secondaryPillBg = Color(0xFFE6FBF5);
  static const Color navInactive = Color(0xFF94A3B8);
  static const Color slate = Color(0xFF94A3B8);
  static const Color slateDark = Color(0xFF334155);
  static const Color slateNavy = Color(0xFF1E293B);
  static const Color slateBlack = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF718096);
  static const Color greenSuccess = Color(0xFF22C55E);
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color blueBright = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF67E8F9);
  static const Color cyanPrimary = Color(0xFF06B6D4);
  static const Color skyDark = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color mintBorder = Color(0xFF86EFAC);
  static const Color mintBg = Color(0xFFF0FDF4);
  static const Color mintSoft = Color(0xFFA7F3D0);
  static const Color borderSlate = Color(0xFFCBD5E1);
  static const Color borderIndigo = Color(0xFFC7D2FE);
  static const Color borderCool = Color(0xFFE2E6EE);
  static const Color indigoAccent = Color(0xFF818CF8);
  static const Color purpleAccent = Color(0xFFA855F7);
  static const Color pinkAccent = Color(0xFFEC4899);
  static const Color orangeAccent = Color(0xFFF57C00);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color orangeLightBg = Color(0xFFFFF3E0);
  static const Color darkRed = Color(0xFF7F1D1D);
  static const Color redDark = Color(0xFF991B1B);
  static const Color redLight = Color(0xFFF87171);
  static const Color redSoft = Color(0xFFFCA5A5);
  static const Color redLightTint = Color(0xFFFEE2E2);
  static const Color redSoftBg = Color(0xFFFFF0F0);
  static const Color redCrimson = Color(0xFFE02424);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color emeraldSoftBg = Color(0xFFE8FDF5);
  static const Color emeraldDarkest = Color(0xFF065F46);
  static const Color emeraldDeep = Color(0xFF047857);
  static const Color lavenderBorder = Color(0xFFDCD8FF);
  static const Color softLavenderBg = Color(0xFFF8F9FD);
  static const Color subtleGrayBg = Color(0xFFF1F3F7);
  static const Color surfaceMuted = Color(0xFFF0F2F6);
  static const Color softCardBg = Color(0xFFFAFBFD);
  static const Color softBlueBg = Color(0xFFF0F4FF);
  static const Color darkCharcoal = Color(0xFF333340);
  static const Color darkSlate = Color(0xFF404050);
  static const Color grayBorder = Color(0xFFC0C0D0);
  static const Color lightGrayDivider = Color(0xFFE9ECEF);
  static const Color overlayDark = Color(0x99000000);

  // Dark Theme
  static const Color darkBackground = Color(0xFF030409);
  static const Color darkSurface = Color(0xFF0A0D16);

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
  static const Color primaryDark = Color(0xFF3F35B5);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color cardSurface = surface;
  static const Color cardBorder = border;
  static const Color grayBackground = background;
  static const Color textPrimary = darkText;
  static const Color textBody = Color(0xFF3A3A50);
  static const Color successDark = Color(0xFF00A979);
}
