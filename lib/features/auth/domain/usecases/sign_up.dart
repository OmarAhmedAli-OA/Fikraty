import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);
  final AuthRepository _repository;

  Future<AuthUser> call({required RegistrationData data}) =>
      _repository.signUp(data: data);
}
