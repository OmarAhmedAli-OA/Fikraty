import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/services/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/home/data/datasources/feed_local_data_source.dart';
import 'features/home/data/repositories/feed_repository_impl.dart';
import 'features/home/presentation/bloc/feed_bloc.dart';
import 'features/home/presentation/bloc/feed_event.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/explore/presentation/pages/explore_page.dart';
import 'features/explore/presentation/pages/compare_startups_page.dart';
import 'features/explore/presentation/bloc/explore_bloc.dart';
import 'features/explore/presentation/bloc/explore_event.dart';
import 'features/home/presentation/pages/messages_page.dart';
import 'features/home/presentation/pages/notifications_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/startups/presentation/pages/my_startups_page.dart';
import 'features/startups/presentation/pages/startup_wizard_page.dart';

void main() {
  configureDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FeedBloc>(
          create: (_) => FeedBloc(
            feedRepository: FeedRepositoryImpl(
              localDataSource: FeedLocalDataSourceImpl(),
            ),
          )..add(const LoadFeedEvent()),
        ),
        BlocProvider<ExploreBloc>(
          create: (_) => sl<ExploreBloc>()..add(const LoadExploreDataEvent()),
        ),
      ],
      child: const FikratyApp(),
    ),
  );
}

class FikratyApp extends StatelessWidget {
  const FikratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fikraty',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => BlocProvider(
          create: (_) => SplashBloc(),
          child: const SplashScreen(),
        ),
        AppRoutes.onboarding: (_) => const OnboardingPage(),
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.resetPassword: (_) => const ResetPasswordPage(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.myStartups: (_) => const MyStartupsPage(),
        AppRoutes.startupWizard: (_) => const StartupWizardPage(),
        AppRoutes.notifications: (_) => const NotificationsPage(),
        AppRoutes.messages: (_) => const MessagesPage(),
        AppRoutes.explore: (_) => const ExplorePage(),
        AppRoutes.compareStartups: (_) => const CompareStartupsPage(),
        // Keep legacy route names working while other features are integrated.
        '/login': (_) => const SignInScreen(),
        '/register': (_) => const SignUpScreen(),
      },
    );
  }
}
