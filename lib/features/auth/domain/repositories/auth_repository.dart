import '../entities/auth.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({required RegistrationData data});
  Future<void> requestPasswordReset({required String email});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<void> verifyEmail({required String email, required String code});
  Future<void> resendVerificationCode({required String email});
  Future<void> signOut();
  Future<AuthUser?> getCurrentUser();
}
