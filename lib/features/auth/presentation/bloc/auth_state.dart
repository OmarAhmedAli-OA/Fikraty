import 'package:equatable/equatable.dart';
import '../../domain/entities/auth.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  passwordResetRequested,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? message,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user?.id, user?.email, user?.role, message];
}
