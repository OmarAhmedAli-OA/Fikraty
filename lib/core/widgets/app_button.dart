import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final dynamic icon; // Widget or IconData
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool expand;

  const AppButton({
    super.key,
    this.text,
    this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 48,
    this.borderRadius = 14,
    this.padding,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = text ?? label ?? '';
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.white;
        borderSide = null;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.primaryLight;
        foregroundColor = AppColors.primary;
        borderSide = null;
        break;
      case AppButtonVariant.outline:
        backgroundColor = AppColors.white;
        foregroundColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.cardBorder, width: 1.2);
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.errorLight;
        foregroundColor = AppColors.error;
        borderSide = const BorderSide(color: AppColors.error, width: 1);
        break;
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget? iconWidget;
    if (icon is Widget) {
      iconWidget = icon as Widget;
    } else if (icon is IconData) {
      iconWidget = Icon(icon as IconData, size: 18, color: foregroundColor);
    }

    final effectiveWidth = expand ? double.infinity : width;

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
          elevation: variant == AppButtonVariant.primary ? 0.5 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.25),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconWidget != null) ...[
                    iconWidget,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      effectiveText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
