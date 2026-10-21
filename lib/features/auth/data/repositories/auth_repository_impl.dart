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
  Future<void> signOut() => _dataSource.signOut();
}
