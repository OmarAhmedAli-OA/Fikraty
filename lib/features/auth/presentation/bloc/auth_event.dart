import 'package:equatable/equatable.dart';
import '../../domain/entities/auth.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({required this.data});
  final RegistrationData data;

  @override
  List<Object?> get props => [data.email, data.profile.fullName, data.role];
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
