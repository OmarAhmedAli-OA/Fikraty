import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      emoji: '🚀',
      headline: 'Connect founders\nwith investors',
      description:
          'Fikraty is the professional ecosystem where startups find capital, and investors find opportunities — with AI-powered matching that explains every recommendation.',
    ),
    _OnboardingSlideData(
      emoji: '🔍',
      headline: 'Discover startups\nwith real data',
      description:
          'Browse 1,800+ verified startups by industry, stage, location, and funding needs. See MRR, growth rates, team profiles, and pitch decks — all in one place.',
    ),
    _OnboardingSlideData(
      emoji: '🤝',
      headline: 'Manage deals\nend-to-end',
      description:
          'From first contact to signed agreement — track your pipeline, run due diligence, negotiate term sheets, and manage your portfolio in private deal rooms.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({bool toSignUp = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      toSignUp ? AppRoutes.signUp : AppRoutes.signIn,
    );
  }

  void _next() {
    if (_currentStep < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(toSignUp: true);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLast = _currentStep == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav: Back & Skip buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: _currentStep > 0 ? 1 : 0,
                    child: IconButton(
                      onPressed: _currentStep > 0 ? _back : null,
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.mutedText),
                      tooltip: 'Back',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _completeOnboarding(toSignUp: true),
                    child: Text(
                      isLast ? 'Skip' : 'Skip intro',
                      style: const TextStyle(
                        color: AppColors.subtleText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Visual Hero Container
                          _buildVisualContainer(index, colors),

                          const SizedBox(height: 32),

                          // Headline
                          Text(
                            _slides[index].headline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                              height: 1.25,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Text(
                            _slides[index].description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.subtleText,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = index == _currentStep;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? colors.primary
                                : AppColors.track,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Primary Button: "Next" or "Get Started"
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          elevation: 3,
                          shadowColor: colors.primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Already have account link
                    GestureDetector(
                      onTap: () => _completeOnboarding(toSignUp: false),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.tertiaryText,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualContainer(int index, ColorScheme colors) {
    if (index == 0) {
      // Slide 1: Matching visualization
      return Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary, AppColors.primaryLight],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 18,
              child: Text(
                '🚀',
                style: TextStyle(fontSize: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileCard(
                    name: 'Sarah',
                    role: 'Founder',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(width: 32),
                  _buildProfileCard(
                    name: 'Omar',
                    role: 'Investor',
                    icon: Icons.business_center_rounded,
                  ),
                ],
              ),
            ),
            // Match badge
            Positioned(
              bottom: 22,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '94% Match',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (index == 1) {
      // Slide 2: Real data bars
      return Container(
        height: 230,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 14),
            _buildStatBar(label: 'HealthTech', count: '62 deals', percentage: 0.68, growth: '+22%'),
            const SizedBox(height: 10),
            _buildStatBar(label: 'AI / ML', count: '91 deals', percentage: 1.0, growth: '+41%'),
            const SizedBox(height: 10),
            _buildStatBar(label: 'FinTech', count: '84 deals', percentage: 0.88, growth: '+28%'),
          ],
        ),
      );
    } else {
      // Slide 3: Pipeline flow
      return Container(
        height: 230,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.secondaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤝', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildPipelinePill('Interest'),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.white70),
                _buildPipelinePill('Meeting'),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.white70),
                _buildPipelinePill('DD'),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.white70),
                _buildPipelinePill('Term Sheet'),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.white70),
                _buildPipelinePill('Closed', isHighlight: true),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileCard({
    required String name,
    required String role,
    required IconData icon,
  }) {
    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.white.withValues(alpha: 0.25),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const Text(
            'Founder',
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required String count,
    required double percentage,
    required String growth,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 42,
          child: Text(
            growth,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPipelinePill(String title, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          color: isHighlight ? AppColors.secondaryDark : AppColors.white,
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.emoji,
    required this.headline,
    required this.description,
  });

  final String emoji;
  final String headline;
  final String description;
}
