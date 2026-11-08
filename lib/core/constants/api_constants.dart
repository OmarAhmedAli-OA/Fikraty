import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract final class ApiConstants {
  /// Base API URL dynamically resolving Android emulator vs Desktop/iOS/Web
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {
      // In web or non-platform contexts
    }
    return 'http://localhost:5000';
  }

  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  static const String authLogoutAll = '/api/auth/logout-all';
  static const String authMe = '/api/auth/me';
  static const String authVerifyEmail = '/api/auth/verify-email';
  static const String authResendVerification = '/api/auth/resend-verification';
  static const String authForgotPassword = '/api/auth/forgot-password';
  static const String authResetPassword = '/api/auth/reset-password';
}
