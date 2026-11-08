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
    this.lockedUntil,
    this.fieldErrors,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? message;
  final DateTime? lockedUntil;
  final Map<String, List<String>>? fieldErrors;

  bool get isLocked => lockedUntil != null && lockedUntil!.isAfter(DateTime.now());

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? message,
    DateTime? lockedUntil,
    Map<String, List<String>>? fieldErrors,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      message: message,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, user?.id, user?.email, user?.role, message, lockedUntil, fieldErrors];
}
