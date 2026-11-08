import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../session/session_manager.dart';
import '../../features/analytics/data/datasources/analytics_local_data_source.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_founder_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_investor_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_startup_analytics_usecase.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/request_password_reset.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/explore/data/datasources/explore_local_data_source.dart';
import '../../features/explore/data/repositories/explore_repository_impl.dart';
import '../../features/explore/domain/repositories/explore_repository.dart';
import '../../features/explore/domain/usecases/express_interest_usecase.dart';
import '../../features/explore/domain/usecases/get_explore_data_usecase.dart';
import '../../features/explore/domain/usecases/toggle_bookmark_usecase.dart';
import '../../features/explore/domain/usecases/toggle_event_registration_usecase.dart';
import '../../features/explore/domain/usecases/toggle_follow_usecase.dart';
import '../../features/explore/presentation/bloc/explore_bloc.dart';
import '../../features/notifications/data/datasources/notifications_local_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/data/services/push_notification_service.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> resetDependencies() async {
  await sl.reset();
}

Future<void> configureDependencies({
  SharedPreferences? preferences,
  bool useMockAuth = false,
}) async {
  if (sl.isRegistered<AuthBloc>()) return;

  final prefs = preferences ?? await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(prefs);
  }

  if (!sl.isRegistered<SessionManager>()) {
    sl.registerLazySingleton<SessionManager>(
      () => SessionManager(sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(sessionManager: sl<SessionManager>()),
    );
  }

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => useMockAuth
        ? FakeAuthRemoteDataSource()
        : AuthRemoteDataSourceImpl(
            apiClient: sl<ApiClient>(),
            sessionManager: sl<SessionManager>(),
          ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerFactory<SignIn>(() => SignIn(sl<AuthRepository>()));
  sl.registerFactory<SignUp>(() => SignUp(sl<AuthRepository>()));
  sl.registerFactory<RequestPasswordReset>(
    () => RequestPasswordReset(sl<AuthRepository>()),
  );
  sl.registerFactory<SignOut>(() => SignOut(sl<AuthRepository>()));

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signIn: sl<SignIn>(),
      signUp: sl<SignUp>(),
      requestPasswordReset: sl<RequestPasswordReset>(),
      signOut: sl<SignOut>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  // Explore Feature Dependencies
  sl.registerLazySingleton<ExploreLocalDataSource>(
    () => ExploreLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(sl<ExploreLocalDataSource>()),
  );

  sl.registerFactory<GetExploreDataUseCase>(
    () => GetExploreDataUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory<ToggleBookmarkUseCase>(
    () => ToggleBookmarkUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory<ExpressInterestUseCase>(
    () => ExpressInterestUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory<ToggleEventRegistrationUseCase>(
    () => ToggleEventRegistrationUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory<ToggleFollowUseCase>(
    () => ToggleFollowUseCase(sl<ExploreRepository>()),
  );

  sl.registerLazySingleton<ExploreBloc>(
    () => ExploreBloc(
      getExploreDataUseCase: sl<GetExploreDataUseCase>(),
      toggleBookmarkUseCase: sl<ToggleBookmarkUseCase>(),
      expressInterestUseCase: sl<ExpressInterestUseCase>(),
      toggleEventRegistrationUseCase: sl<ToggleEventRegistrationUseCase>(),
      toggleFollowUseCase: sl<ToggleFollowUseCase>(),
    ),
  );

  // Notifications Feature Dependencies (Prepared for Backend and FCM)
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationServiceImpl(),
  );
  sl.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<NotificationsLocalDataSource>()),
  );

  sl.registerFactory<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationsRepository>()),
  );
  sl.registerFactory<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(sl<NotificationsRepository>()),
  );
  sl.registerFactory<MarkAllNotificationsAsReadUseCase>(
    () => MarkAllNotificationsAsReadUseCase(sl<NotificationsRepository>()),
  );

  sl.registerLazySingleton<NotificationsBloc>(
    () => NotificationsBloc(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      markNotificationAsReadUseCase: sl<MarkNotificationAsReadUseCase>(),
      markAllNotificationsAsReadUseCase:
          sl<MarkAllNotificationsAsReadUseCase>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );
  // Analytics Feature Dependencies
  sl.registerLazySingleton<AnalyticsLocalDataSource>(
    () => AnalyticsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl<AnalyticsLocalDataSource>()),
  );

  sl.registerFactory<GetFounderAnalyticsUseCase>(
    () => GetFounderAnalyticsUseCase(sl<AnalyticsRepository>()),
  );
  sl.registerFactory<GetStartupAnalyticsUseCase>(
    () => GetStartupAnalyticsUseCase(sl<AnalyticsRepository>()),
  );
  sl.registerFactory<GetInvestorAnalyticsUseCase>(
    () => GetInvestorAnalyticsUseCase(sl<AnalyticsRepository>()),
  );

  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(
      getFounderAnalyticsUseCase: sl<GetFounderAnalyticsUseCase>(),
      getStartupAnalyticsUseCase: sl<GetStartupAnalyticsUseCase>(),
      getInvestorAnalyticsUseCase: sl<GetInvestorAnalyticsUseCase>(),
    ),
  );
}
