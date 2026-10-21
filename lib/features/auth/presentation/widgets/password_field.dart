import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      validator: widget.validator,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffix: IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      ),
    );
  }
}
