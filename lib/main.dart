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
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/startups/presentation/pages/my_startups_page.dart';

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
        AppRoutes.home: (_) => const FikratyHomePage(),
        // Keep legacy route names working while other features are integrated.
        '/login': (_) => const SignInScreen(),
        '/register': (_) => const SignUpScreen(),
      },
    );
  }
}

class FikratyHomePage extends StatelessWidget {
  const FikratyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentRole = context.select<AuthBloc, String?>(
      (bloc) => bloc.state.user?.role.name,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Fikraty',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(Icons.lightbulb_outline_rounded, size: 56, color: colors.primary),
                ),
                const SizedBox(height: 24),
                Text('Welcome to Fikraty!', textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text(
                  'Discover ideas. Share your vision. Build your future.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (currentRole != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Prototype role: ${currentRole == 'investor' ? 'Investor' : 'Entrepreneur'}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Home screen integration is the next phase.')),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
