import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/domain/entities/user_profile.dart' as up;
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../startups/data/datasources/startups_remote_data_source.dart';
import '../../../startups/data/models/startups_model.dart';
import '../../../startups/domain/entities/startups.dart';
import '../../../startups/presentation/pages/my_startups_page.dart';
import '../../../startups/presentation/pages/startup_wizard_page.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.onSelectStartupsTab});

  final VoidCallback? onSelectStartupsTab;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _hasStartup = false;

  @override
  void initState() {
    super.initState();
    _checkStartupStatus();
  }

  Future<void> _checkStartupStatus() async {
    // 1. Check local datasource
    try {
      final startup = await StartupsLocalDataSourceImpl().getMyStartup();
      if (startup != null && startup.name.trim().isNotEmpty) {
        if (mounted) setState(() => _hasStartup = true);
        return;
      }
    } catch (_) {}

    if (!mounted) return;

    // 2. Check AuthBloc
    try {
      final authUser = context.read<AuthBloc>().state.user;
      if (authUser != null) {
        if (authUser.startup != null &&
            authUser.startup!.name.trim().isNotEmpty) {
          if (mounted) setState(() => _hasStartup = true);
          return;
        }
      }
    } catch (_) {}

    if (!mounted) return;

    // 3. Check ProfileBloc
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoadedState) {
        if (profileState.profile.role == up.UserRole.entrepreneur &&
            profileState.profile.companyName.trim().isNotEmpty) {
          if (StartupsLocalDataSourceImpl().currentStartup == null) {
            StartupsLocalDataSourceImpl().currentStartup = StartupModel(
              id: profileState.profile.id,
              ownerUserId: profileState.profile.id,
              name: profileState.profile.companyName,
              tagline: profileState.profile.title,
              description: profileState.profile.bio,
              problem: 'Problem statement for ${profileState.profile.companyName}',
              solution: 'Innovative solution provided by ${profileState.profile.companyName}',
              businessModel: 'B2B SaaS subscription',
              targetMarket: 'MENA Region',
              industryName: profileState.profile.industry.isNotEmpty
                  ? profileState.profile.industry
                  : 'FinTech',
              stageName: profileState.profile.companyStage.isNotEmpty
                  ? profileState.profile.companyStage
                  : 'Seed',
              cityName: profileState.profile.location.isNotEmpty
                  ? profileState.profile.location
                  : 'Cairo, Egypt',
              logoUrl: profileState.profile.photoUrl,
              coverImageUrl: profileState.profile.coverUrl,
              websiteUrl: profileState.profile.website,
            );
          }
          if (mounted) setState(() => _hasStartup = true);
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _hasStartup = false);
  }

  final List<String> _categories = [
    'All',
    'FinTech',
    'HealthTech',
    'AI & Data',
    'EdTech',
    'CleanTech',
    'E-Commerce',
  ];

  final List<Map<String, dynamic>> _mockStartups = [
    {
      'name': 'FikraPay',
      'category': 'FinTech',
      'stage': 'Seed',
      'raised': '\$250K / \$500K',
      'description': 'AI-driven financial management and instant payment rails for MENA SMEs.',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'SehaCloud',
      'category': 'HealthTech',
      'stage': 'Pre-Seed',
      'raised': '\$80K / \$200K',
      'description': 'Integrated telemedicine and electronic health record platform for clinics.',
      'icon': Icons.health_and_safety_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'name': 'AgriSense Egypt',
      'category': 'CleanTech',
      'stage': 'Seed',
      'raised': '\$350K / \$600K',
      'description': 'Smart IoT sensors for precision irrigation and soil nutrient tracking.',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF059669),
    },
    {
      'name': 'DarsOnline',
      'category': 'EdTech',
      'stage': 'Series A',
      'raised': '\$1.2M / \$2M',
      'description': 'Interactive Arabic tutoring platform with automated progress assessments.',
      'icon': Icons.school_rounded,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStartups = _mockStartups.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          (item['name'] as String).toLowerCase().contains(query) ||
          (item['description'] as String).toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Explore Startups & Ideas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search startups, sectors, or ideas...',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                      selectedColor: AppColors.primaryPurple,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.ink,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryPurple : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Call to Action Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you a Founder?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hasStartup
                        ? 'Manage your startup profile, view deal metrics, and update your pitch.'
                        : 'Create your startup profile, get verified, and match with active investors.',
                    style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_hasStartup)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyStartupsPage(),
                              ),
                            ).then((_) => _checkStartupStatus());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                          label: const Text(
                            'My Startup',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push<StartupEntity>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StartupWizardPage(),
                              ),
                            );
                            if (result != null) {
                              await _checkStartupStatus();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'New Startup Wizard',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Featured Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Startups (${filteredStartups.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Startups List
            ...filteredStartups.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['category'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['stage'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['raised'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['description'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
