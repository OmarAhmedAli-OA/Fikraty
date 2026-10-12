import 'package:flutter/material.dart';

void main() {
  runApp(const FikratyApp());
}

class FikratyApp extends StatelessWidget {
  const FikratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fikraty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3A6E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFBFD),
      ),
      home: const FikratyHomePage(),
    );
  }
}

class FikratyHomePage extends StatelessWidget {
  const FikratyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fikraty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
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
                  color: colors.primary.withValues(alpha: 0.1),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover ideas. Share your vision. Build your future.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.6),
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
