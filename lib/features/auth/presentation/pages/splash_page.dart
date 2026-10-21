import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../splash/presentation/bloc/splash_bloc.dart';
import '../../../splash/presentation/pages/splash_screen.dart';

/// Compatibility wrapper; the app router provides the same SplashBloc.
class AuthSplashPage extends StatelessWidget {
  const AuthSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc(),
      child: const SplashScreen(),
    );
  }
}
