import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _localError = null);
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(AuthSignInRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
            } else if (state.status == AuthStatus.failure && state.message != null) {
              setState(() => _localError = state.message);
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back to onboarding
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.mutedText),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logo and Brand Title
                      const AppLogo(size: 40, showText: true),
                      const SizedBox(height: 28),

                      // Heading
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Email or Username Field
                      const Text(
                        'EMAIL OR USERNAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Enter your email, username, or phone number.';
                          }
                          if (trimmed.length > 254) {
                            return 'Identifier cannot exceed 254 characters.';
                          }
                          if (trimmed.contains('@')) {
                            final atIndex = trimmed.indexOf('@');
                            if (atIndex <= 0 || atIndex != trimmed.lastIndexOf('@')) {
                              return 'Enter a valid email address.';
                            }
                            final domain = trimmed.substring(atIndex + 1);
                            if (!domain.contains('.') || domain.startsWith('.') || domain.endsWith('.')) {
                              return 'Enter a valid email address.';
                            }
                          }
                          return null;
                        },
                        style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                        decoration: InputDecoration(
                          hintText: 'you@startup.com or username',
                          hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 14),
                          fillColor: AppColors.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 14),
                          fillColor: AppColors.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.primary, width: 1.5),
                          ),
                          suffixIcon: TextButton(
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                            child: Text(
                              _showPassword ? 'Hide' : 'Show',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),

                      // Error message banner
                      if (_localError != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _localError!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Sign In Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                elevation: 3,
                                shadowColor: colors.primary.withValues(alpha: 0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Quick Prototype Demo Accounts Pill

                      // Don't have account footer
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.subtleText,
                                fontFamily: 'Inter',
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Create one',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
