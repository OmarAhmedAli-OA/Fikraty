import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fikraty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fikraty/features/auth/domain/entities/auth.dart';
import 'package:fikraty/features/auth/domain/usecases/request_password_reset.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_in.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_out.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_up.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_event.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_state.dart';

void main() {
  late AuthBloc bloc;
  late FakeAuthRemoteDataSource dataSource;

  RegistrationData entrepreneurRegistration({String email = 'founder@example.com'}) => RegistrationData(
        email: email,
        password: 'Secure-demo-password-123',
        role: UserRole.entrepreneur,
        profile: const UserProfileData(fullName: 'Founder User', professionalTitle: 'Founder'),
        startup: const StartupRegistrationData(
          name: 'Fikraty Labs',
          industry: LookupSelection(code: 'technology', label: 'Technology'),
          stage: LookupSelection(code: 'MVP', label: 'MVP'),
        ),
      );

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(dataSource);
    bloc = AuthBloc(
      signIn: SignIn(repository),
      signUp: SignUp(repository),
      requestPasswordReset: RequestPasswordReset(repository),
      signOut: SignOut(repository),
    );
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'registers a complete entrepreneur record and authenticates',
    build: () => bloc,
    act: (bloc) => bloc.add(AuthSignUpRequested(data: entrepreneurRegistration())),
    wait: const Duration(milliseconds: 300),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      isA<AuthState>()
          .having((state) => state.status, 'status', AuthStatus.authenticated)
          .having((state) => state.user?.email, 'email', 'founder@example.com')
          .having((state) => state.user?.role, 'role', UserRole.entrepreneur)
          .having((state) => state.user?.startup?.name, 'startup name', 'Fikraty Labs')
          .having((state) => state.user?.profile.fullName, 'full name', 'Founder User'),
    ],
  );

  test('sign-in uses the registered email, password, role and profile', () async {
    final registered = await dataSource.signUp(entrepreneurRegistration());
    final signedIn = await dataSource.signIn(' FOUNDER@example.com ', 'Secure-demo-password-123');
    expect(signedIn.id, registered.id);
    expect(signedIn.role, UserRole.entrepreneur);
    expect(signedIn.profile.fullName, 'Founder User');
    expect(signedIn.startup?.industry.code, 'technology');
  });

  test('rejects sign-in for an unknown email or incorrect password', () async {
    await expectLater(
      dataSource.signIn('missing@example.com', 'wrong-password'),
      throwsA(isA<AuthDataException>()),
    );
    await dataSource.signUp(entrepreneurRegistration());
    await expectLater(
      dataSource.signIn('founder@example.com', 'wrong-password'),
      throwsA(isA<AuthDataException>()),
    );
  });

  test('rejects duplicate email registration', () async {
    await dataSource.signUp(entrepreneurRegistration());
    await expectLater(
      dataSource.signUp(entrepreneurRegistration()),
      throwsA(isA<AuthDataException>()),
    );
  });

  test('investor registration retains profile and all selected preferences', () async {
    final registration = RegistrationData(
      email: 'investor@example.com',
      password: 'Secure-demo-password-123',
      role: UserRole.investor,
      profile: const UserProfileData(fullName: 'Investor User'),
      investor: const InvestorRegistrationData(
        firmName: 'Demo Ventures',
        investorType: 'Angel',
        thesis: 'Early-stage technology startups',
        ticketMin: 10000,
        ticketMax: 50000,
        currency: LookupSelection(code: 'USD', label: 'USD'),
        riskPreference: InvestorRiskPreference.medium,
        preferredIndustries: [LookupSelection(code: 'technology', label: 'Technology')],
        preferredCountries: [LookupSelection(code: 'EG', label: 'Egypt')],
        preferredStages: [LookupSelection(code: 'MVP', label: 'MVP')],
        providesSmartMoney: true,
        providesDebt: false,
      ),
    );

    final user = await dataSource.signUp(registration);
    expect(user.role, UserRole.investor);
    expect(user.investor?.firmName, 'Demo Ventures');
    expect(user.investor?.ticketMin, 10000);
    expect(user.investor?.preferredIndustries.single.code, 'technology');
    expect(user.investor?.preferredCountries.single.code, 'EG');
    expect(user.investor?.preferredStages.single.code, 'MVP');
    expect(user.investor?.providesSmartMoney, isTrue);
  });
}
