import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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

  void _checkAndNavigate() {
    if (_isAnimationCompleted && _isInitCompleted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // Automatically uses the white background from your Light Theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashSuccess || state is SplashFailure) {
            _isInitCompleted = true;
            _checkAndNavigate();
          }
        },
        child: Center(
          child: Lottie.asset(isDarkMode
              ? 'assets/animations/splash_logo_dark.json'
              : 'assets/animations/splash_logo.json',
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