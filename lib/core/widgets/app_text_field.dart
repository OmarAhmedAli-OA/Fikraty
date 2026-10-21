import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.hintText,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
    this.prefixText,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? hintText;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final String? prefixText;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? hint;
    final effectiveSuffix = suffixIcon ?? suffix;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          autofillHints: autofillHints,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,
          autocorrect: false,
          enableSuggestions: !obscureText,
          decoration: InputDecoration(
            hintText: effectiveHint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            suffixIcon: effectiveSuffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
