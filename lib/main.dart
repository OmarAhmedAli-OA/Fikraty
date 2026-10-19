import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() {
  runApp(
    BlocProvider(create: (context) => ThemeCubit(), child: const FikratyApp()),
  );
}

class FikratyApp extends StatelessWidget {
  const FikratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentThemeMode) {
        return MaterialApp(
          title: 'Fikraty',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentThemeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider(
              create: (context) => SplashBloc(),
              child: const SplashScreen(),
            ),
            '/home': (context) => const FikratyHomePage(),
          },
        );
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fikraty',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
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
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 56,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Fikraty!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Discover ideas. Share your vision. Build your future.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fikraty is getting ready!')),
                  );
                },
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
