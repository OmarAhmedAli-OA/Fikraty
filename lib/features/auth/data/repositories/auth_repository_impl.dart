import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      _dataSource.signIn(email, password);

  @override
  Future<AuthUser> signUp({required RegistrationData data}) =>
      _dataSource.signUp(data);

  @override
  Future<void> requestPasswordReset({required String email}) =>
      _dataSource.requestPasswordReset(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) =>
      _dataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

  @override
  Future<void> verifyEmail({required String email, required String code}) =>
      _dataSource.verifyEmail(email: email, code: code);

  @override
  Future<void> resendVerificationCode({required String email}) =>
      _dataSource.resendVerificationCode(email);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<AuthUser?> getCurrentUser() => _dataSource.getCurrentUser();
}
