import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/request_password_reset.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  if (sl.isRegistered<AuthBloc>()) return;

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FakeAuthRemoteDataSource(),
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
    ),
  );
}
