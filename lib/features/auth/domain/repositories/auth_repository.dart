import '../entities/auth.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({required RegistrationData data});
  Future<void> requestPasswordReset({required String email});
  Future<void> signOut();
}
