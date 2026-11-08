import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/repositories/auth_repository.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _codeController = TextEditingController();
  String _email = '';
  bool _initializedArgs = false;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _infoMessage;

  Timer? _resendTimer;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _email = args;
      } else if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
        _email = widget.initialEmail!;
      } else {
        final session = sl.isRegistered<SessionManager>() ? sl<SessionManager>() : null;
        _email = session?.cachedUser?.email ?? '';
      }
      _initializedArgs = true;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();

    if (code.isEmpty || code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit code sent to your email.';
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      final authRepo = sl<AuthRepository>();
      await authRepo.verifyEmail(email: _email, code: code);

      if (sl.isRegistered<SessionManager>()) {
        await sl<SessionManager>().setEmailConfirmed(true);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });

        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        final rawMsg = e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthDataException: ', '');
        setState(() {
          _isLoading = false;
          _errorMessage = rawMsg.isNotEmpty ? rawMsg : 'Invalid verification code. Please try again.';
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      final authRepo = sl<AuthRepository>();
      await authRepo.resendVerificationCode(email: _email);

      if (mounted) {
        setState(() {
          _isResending = false;
          _infoMessage = 'A new 6-digit code has been sent to your email.';
        });
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        final rawMsg = e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthDataException: ', '');
        setState(() {
          _isResending = false;
          _errorMessage = rawMsg.isNotEmpty ? rawMsg : 'Unable to resend code right now.';
        });
      }
    }
  }

  void _onSkip() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppLogo(size: 38, showText: true),
                  const SizedBox(height: 36),

                  // Envelope Icon Badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('✉️', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Description
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit verification code to:',
                    style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email.isNotEmpty ? _email : 'your email address',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 6-digit Code input
                  const Text(
                    'ENTER 6-DIGIT CODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8.0,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: const TextStyle(
                        color: AppColors.inputHint,
                        fontSize: 22,
                        letterSpacing: 8.0,
                      ),
                      fillColor: AppColors.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  const SizedBox(height: 18),

                  // Error / Info banners
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_infoMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _infoMessage!,
                        style: const TextStyle(color: AppColors.success, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 3,
                        shadowColor: colors.primary.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _isSuccess ? 'Verified!' : 'Verify Email',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Resend code option
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code? ",
                        style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                      ),
                      if (_resendCooldown > 0)
                        Text(
                          'Resend in ${_resendCooldown}s',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedText,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _isResending ? null : _handleResend,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isResending ? 'Sending...' : 'Resend code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Skip for now button
                  Center(
                    child: TextButton(
                      onPressed: _onSkip,
                      child: const Text(
                        'Skip for now (Continue to Home)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
