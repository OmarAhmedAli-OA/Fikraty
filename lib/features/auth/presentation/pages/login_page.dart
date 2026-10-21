import 'package:flutter/material.dart';
import 'sign_in_page.dart';

/// Backward-compatible wrapper for older imports.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const SignInScreen();
}
