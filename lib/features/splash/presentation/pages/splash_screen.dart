import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isAnimationCompleted = false;
  bool _isInitCompleted = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    context.read<SplashBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    if (!_isAnimationCompleted || !_isInitCompleted || _hasNavigated) return;
    _hasNavigated = true;
    var hasCompletedOnboarding = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      hasCompletedOnboarding =
          preferences.getBool('onboarding_completed') ?? false;
    } catch (_) {
      // If preferences are unavailable, safely fall back to onboarding.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      hasCompletedOnboarding ? AppRoutes.signIn : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashSuccess || state is SplashFailure) {
            _isInitCompleted = true;
            _checkAndNavigate();
          }
        },
        child: Center(
          child: Lottie.asset(
            'assets/animations/splash_logo.json',
            controller: _controller,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitHeight,
            onLoaded: (composition) {
              _controller.duration = composition.duration;
              _controller.forward().whenComplete(() {
                _isAnimationCompleted = true;
                _checkAndNavigate();
              });
            },
          ),
        ),
      ),
    );
  }
}
