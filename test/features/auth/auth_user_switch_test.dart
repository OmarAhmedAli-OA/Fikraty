import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fikraty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fikraty/features/auth/domain/entities/auth.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_in.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_out.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_up.dart';
import 'package:fikraty/features/auth/domain/usecases/request_password_reset.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_event.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_state.dart';

void main() {
  test('investor signup, founder signup, then investor signin', () async {
    final ds = FakeAuthRemoteDataSource();
    final repo = AuthRepositoryImpl(ds);
    final bloc = AuthBloc(
      signIn: SignIn(repo),
      signUp: SignUp(repo),
      requestPasswordReset: RequestPasswordReset(repo),
      signOut: SignOut(repo),
    );

    // 1. Sign up as Investor
    final invData = RegistrationData(
      email: 'investor1@test.com',
      password: 'password123',
      role: UserRole.investor,
      profile: const UserProfileData(fullName: 'Investor One'),
      investor: const InvestorRegistrationData(
        thesis: 'FinTech',
        ticketSize: r'$50K - $100K',
      ),
    );
    bloc.add(AuthSignUpRequested(data: invData));
    await Future.delayed(const Duration(milliseconds: 300));
    expect(bloc.state.user?.role, UserRole.investor);
    expect(bloc.state.user?.email, 'investor1@test.com');

    // 2. Sign out
    bloc.add(const AuthSignOutRequested());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(bloc.state.status, AuthStatus.unauthenticated);
    expect(bloc.state.user, isNull);

    // 3. Sign up as Founder
    final founderData = RegistrationData(
      email: 'founder1@test.com',
      password: 'password123',
      role: UserRole.entrepreneur,
      profile: const UserProfileData(fullName: 'Founder One'),
      startup: const StartupRegistrationData(
        name: 'Startup One',
        industry: LookupSelection(code: 'tech', label: 'Tech'),
        stage: LookupSelection(code: 'seed', label: 'Seed'),
      ),
    );
    bloc.add(AuthSignUpRequested(data: founderData));
    await Future.delayed(const Duration(milliseconds: 300));
    expect(bloc.state.user?.role, UserRole.entrepreneur);
    expect(bloc.state.user?.email, 'founder1@test.com');

    // 4. Sign out
    bloc.add(const AuthSignOutRequested());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(bloc.state.status, AuthStatus.unauthenticated);
    expect(bloc.state.user, isNull);

    // 5. Sign in as Investor
    bloc.add(const AuthSignInRequested(
      email: 'investor1@test.com',
      password: 'password123',
    ));
    await Future.delayed(const Duration(milliseconds: 300));
    expect(bloc.state.user?.role, UserRole.investor);
    expect(bloc.state.user?.email, 'investor1@test.com');
  });
}
