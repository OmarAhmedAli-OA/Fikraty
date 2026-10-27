import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/core/constants/countries.dart';
import 'package:fikraty/core/utils/validators.dart';
import 'package:fikraty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fikraty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fikraty/features/auth/domain/entities/auth.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_in.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_out.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_up.dart';
import 'package:fikraty/features/auth/domain/usecases/request_password_reset.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fikraty/features/explore/data/datasources/explore_local_data_source.dart';
import 'package:fikraty/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:fikraty/features/explore/domain/usecases/get_explore_data_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_bookmark_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/express_interest_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_event_registration_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_follow_usecase.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_event.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_state.dart';

void main() {
  group('International & Local Phone Validation', () {
    test('accepts valid international mobile numbers with country codes', () {
      expect(Validators.phone('+14155552671'), isNull); // US
      expect(Validators.phone('+966512345678'), isNull); // Saudi
      expect(Validators.phone('+971501234567'), isNull); // UAE
      expect(Validators.phone('+447911123456'), isNull); // UK
      expect(Validators.phone('+201012345678'), isNull); // Egypt with +20
      expect(Validators.phone('00966512345678'), isNull); // 00 prefix
    });

    test('accepts valid local Egyptian mobile numbers', () {
      expect(Validators.phone('01012345678'), isNull);
      expect(Validators.phone('01112345678'), isNull);
      expect(Validators.phone('01212345678'), isNull);
      expect(Validators.phone('01512345678'), isNull);
    });

    test('rejects arbitrary, invalid or dummy phone numbers', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('12345'), isNotNull); // too short
      expect(Validators.phone('11111111111'), isNotNull); // repeating digits
      expect(Validators.phone('abcdefghijk'), isNotNull);
    });

    test('normalizes international numbers to + format', () {
      expect(Validators.normalizePhone('00966512345678'), '+966512345678');
      expect(Validators.normalizePhone('010 1234 5678'), '01012345678');
      expect(Validators.normalizePhone('+1 (415) 555-2671'), '+14155552671');
    });
  });

  group('Country Resolver', () {
    test('resolves USA, US, United States accurately', () {
      final countryUSA = AppCountries.resolve('USA');
      expect(countryUSA.code, 'US');
      expect(countryUSA.name, 'United States');

      final countryUS = AppCountries.resolve('US');
      expect(countryUS.code, 'US');

      final countryNY = AppCountries.resolve('New York, USA');
      expect(countryNY.code, 'US');
    });

    test('resolves Egypt and UAE accurately', () {
      final countryEG = AppCountries.resolve('Cairo, Egypt');
      expect(countryEG.code, 'EG');

      final countryAE = AppCountries.resolve('Dubai, UAE');
      expect(countryAE.code, 'AE');
    });
  });

  group('Sign Up -> Sign Out -> Sign In Flow', () {
    late FakeAuthRemoteDataSource dataSource;
    late AuthBloc authBloc;

    setUp(() {
      dataSource = FakeAuthRemoteDataSource();
      final repo = AuthRepositoryImpl(dataSource);
      authBloc = AuthBloc(
        signIn: SignIn(repo),
        signUp: SignUp(repo),
        requestPasswordReset: RequestPasswordReset(repo),
        signOut: SignOut(repo),
      );
    });

    tearDown(() => authBloc.close());

    test('allows user to sign up, sign out, and sign back in with email or phone', () async {
      // 1. Sign Up
      final regData = RegistrationData(
        email: 'founder.global@example.com',
        password: 'Password123!',
        role: UserRole.entrepreneur,
        phone: '+14155552671',
        profile: const UserProfileData(fullName: 'Alex Founder', location: 'USA'),
        startup: const StartupRegistrationData(
          name: 'Global Ventures AI',
          industry: LookupSelection(code: 'ai', label: 'AI / ML'),
          stage: LookupSelection(code: 'seed', label: 'Seed'),
        ),
      );

      final user = await dataSource.signUp(regData);
      expect(user.email, 'founder.global@example.com');

      // 2. Sign Out
      await dataSource.signOut();
      expect(dataSource.currentUser, isNull);

      // 3. Sign In with Email
      final signedInEmail = await dataSource.signIn('founder.global@example.com', 'Password123!');
      expect(signedInEmail.id, user.id);
      expect(signedInEmail.profile.fullName, 'Alex Founder');

      // 4. Sign In with Phone
      final signedInPhone = await dataSource.signIn('+14155552671', 'Password123!');
      expect(signedInPhone.id, user.id);

      // 5. Sign In with Name/Username
      final signedInName = await dataSource.signIn('Alex Founder', 'Password123!');
      expect(signedInName.id, user.id);
    });
  });

  group('Explore Feature Integration', () {
    late ExploreLocalDataSource dataSource;
    late ExploreBloc exploreBloc;

    setUp(() {
      dataSource = ExploreLocalDataSourceImpl();
      final repo = ExploreRepositoryImpl(dataSource);
      exploreBloc = ExploreBloc(
        getExploreDataUseCase: GetExploreDataUseCase(repo),
        toggleBookmarkUseCase: ToggleBookmarkUseCase(repo),
        expressInterestUseCase: ExpressInterestUseCase(repo),
        toggleEventRegistrationUseCase: ToggleEventRegistrationUseCase(repo),
        toggleFollowUseCase: ToggleFollowUseCase(repo),
      );
    });

    tearDown(() => exploreBloc.close());

    test('loads explore data cleanly and handles bookmarks and tabs', () async {
      exploreBloc.add(const LoadExploreDataEvent());
      await expectLater(
        exploreBloc.stream,
        emitsInOrder([
          isA<ExploreLoadingState>(),
          isA<ExploreLoadedState>().having(
            (s) => s.startups.isNotEmpty,
            'startups not empty',
            true,
          ),
        ]),
      );

      // Change tab
      exploreBloc.add(const ChangeExploreTabEvent(1));
      await expectLater(
        exploreBloc.stream,
        emits(isA<ExploreLoadedState>().having((s) => s.selectedTabIndex, 'tabIndex', 1)),
      );

      // Bookmark a startup
      exploreBloc.add(const ToggleBookmarkEvent(type: 'startup', id: 1));
      await expectLater(
        exploreBloc.stream,
        emits(isA<ExploreLoadedState>().having((s) => s.feedbackMessage, 'msg', isNotNull)),
      );

      // Follow investor persists in state
      exploreBloc.add(const ToggleFollowEvent(type: 'investor', id: 1));
      await expectLater(
        exploreBloc.stream,
        emits(isA<ExploreLoadedState>().having(
          (s) => s.investors.firstWhere((i) => i.id == 1).isFollowing,
          'investor isFollowing',
          true,
        )),
      );

      // Follow founder persists in state and increments followers
      exploreBloc.add(const ToggleFollowEvent(type: 'founder', id: 1));
      await expectLater(
        exploreBloc.stream,
        emits(isA<ExploreLoadedState>().having(
          (s) => s.founders.firstWhere((f) => f.id == 1).isFollowing,
          'founder isFollowing',
          true,
        )),
      );

      // Express interest in startup persists in state
      exploreBloc.add(const ExpressInterestEvent(type: 'startup', id: 1));
      await expectLater(
        exploreBloc.stream,
        emits(isA<ExploreLoadedState>().having(
          (s) => s.startups.firstWhere((st) => st.id == 1).isInterested,
          'startup isInterested',
          true,
        )),
      );
    });
  });
}
