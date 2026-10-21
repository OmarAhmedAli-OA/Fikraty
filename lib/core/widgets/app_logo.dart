import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 48,
    this.showText = false,
    this.textColor,
    super.key,
  });

  final double size;
  final bool showText;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final iconBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: size * 0.25,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: Image.asset(
        'assets/icons/app_mark.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to splash_logo.png (already present in existing builds)
          return ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.18),
            child: OverflowBox(
              maxHeight: size * 2.2,
              maxWidth: size * 2.2,
              alignment: const Alignment(0, -0.42),
              child: Image.asset(
                'assets/icons/splash_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.lightbulb_rounded,
                    size: size * 0.60,
                    color: primaryColor,
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    if (!showText) return iconBox;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconBox,
        const SizedBox(width: 10),
        Text(
          'Fikraty',
          style: TextStyle(
            fontSize: size * 0.55 > 18 ? size * 0.55 : 22,
            fontWeight: FontWeight.w800,
            color: textColor ?? AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
