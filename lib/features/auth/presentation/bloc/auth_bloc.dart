import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_manager.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/usecases/request_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.requestPasswordReset,
    required this.signOut,
    this.sessionManager,
  }) : super(const AuthState()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthCheckSessionRequested>(_onCheckSession);
  }

  final SignIn signIn;
  final SignUp signUp;
  final RequestPasswordReset requestPasswordReset;
  final SignOut signOut;
  final SessionManager? sessionManager;

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final cached = sessionManager?.cachedUser;
    if (sessionManager?.isAuthenticated == true && cached != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: cached));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await signIn(
        email: event.email.trim(),
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthDataException catch (e) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: e.message.isNotEmpty ? e.message : 'Unable to sign in right now. Please try again.',
        lockedUntil: e.lockedUntil,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      final msg = e.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('AuthDataException: ', '');
      emit(AuthState(
        status: AuthStatus.failure,
        message: msg.isNotEmpty ? msg : 'Unable to sign in right now. Please try again.',
      ));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await signUp(data: event.data);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      final msg = e.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('AuthDataException: ', '');
      emit(AuthState(
        status: AuthStatus.failure,
        message: msg.isNotEmpty ? msg : 'Unable to create your account right now. Please try again.',
      ));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await requestPasswordReset(email: event.email.trim());
      emit(const AuthState(
        status: AuthStatus.passwordResetRequested,
        message: 'If an account exists for this email, recovery instructions will be sent.',
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Unable to process the request right now. Please try again.',
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signOut();
    } catch (_) {
      // Always clear local UI state after a sign-out request.
    }
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
