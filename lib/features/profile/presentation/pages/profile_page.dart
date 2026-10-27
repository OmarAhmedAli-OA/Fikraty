import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/domain/entities/auth.dart' as auth;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../home/domain/entities/post.dart';
import '../../../home/presentation/pages/post_detail_page.dart';
import '../../../startups/data/repositories/startups_repository_impl.dart';
import '../../../startups/domain/entities/startups.dart';
import '../../../startups/presentation/bloc/startups_bloc.dart';
import '../../../startups/presentation/pages/startup_wizard_page.dart';
import '../../../startups/presentation/widgets/custom_startup_image.dart';
import '../../../startups/presentation/widgets/startup_member_tile.dart';
import '../../../startups/presentation/pages/submit_verification_page.dart';
import '../../data/datasources/profile_dummy_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_interests.dart';
import '../../domain/usecases/get_investor_preferences.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/switch_role.dart';
import '../../domain/usecases/update_interest_status.dart';
import '../../domain/usecases/update_investor_preferences.dart';
import '../../domain/usecases/update_profile.dart';
import '../bloc/investor_preferences/investor_preferences_bloc.dart';
import '../bloc/investor_preferences/investor_preferences_event.dart';
import '../bloc/investor_preferences/investor_preferences_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import 'edit_profile_page.dart';
import 'interests_page.dart';
import 'investor_preferences_page.dart';
import 'my_analytics_page.dart';
import 'settings_page.dart';
import 'startup_analytics_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final initialRole = authUser?.role == auth.UserRole.investor
        ? UserRole.investor
        : UserRole.entrepreneur;
    final dataSource = ProfileDummyDataSource(authUser: authUser);
    final repo = ProfileRepositoryImpl(dataSource: dataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            getProfileUseCase: GetProfileUseCase(repo),
            updateProfileUseCase: UpdateProfileUseCase(repo),
            switchRoleUseCase: SwitchRoleUseCase(repo),
            getInterestsUseCase: GetInterestsUseCase(repo),
            updateInterestStatusUseCase: UpdateInterestStatusUseCase(repo),
            profileRepository: repo,
          )..add(LoadProfileEvent(role: initialRole)),
        ),
        BlocProvider<InvestorPreferencesBloc>(
          create: (_) => InvestorPreferencesBloc(
            getInvestorPreferencesUseCase:
                GetInvestorPreferencesUseCase(repo),
            updateInvestorPreferencesUseCase:
                UpdateInvestorPreferencesUseCase(repo),
          )..add(const LoadInvestorPreferencesEvent()),
        ),
      ],
      child: const _ProfilePageBody(),
    );
  }
}

class _ProfilePageBody extends StatefulWidget {
  const _ProfilePageBody();

  @override
  State<_ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<_ProfilePageBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _shareNotice;

  StartupEntity? _startup;
  final List<StartupMemberEntity> _teamMembers = [
    const StartupMemberEntity(
      id: 'mem-1',
      fullName: 'Kareem Tarek',
      roleTitle: 'CTO & Head of AI',
      bio: 'Ex-Google ML Engineer with 7+ years in computer vision and medical imaging.',
      isCofounder: true,
    ),
    const StartupMemberEntity(
      id: 'mem-2',
      fullName: 'Nour El-Din',
      roleTitle: 'Lead Product Designer',
      bio: 'Specialized in healthcare UX and clinical workflow optimization.',
      isCofounder: false,
    ),
  ];

  final List<Map<String, dynamic>> _milestones = [
    {'title': 'MVP Launch & Beta Testing', 'date': 'Q1 2026', 'done': true},
    {'title': '10 Clinics Onboarded in Egypt & UAE', 'date': 'Q2 2026', 'done': true},
    {'title': 'Seed Round \$2.4M Closing', 'date': 'Q3 2026', 'done': true},
    {'title': 'Expansion into Saudi Arabia (KSA)', 'date': 'Q4 2026', 'done': false},
    {'title': 'CE / Legal HealthTech Certification', 'date': 'Q1 2027', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    // 3 sections: 1. Posts, 2. My Startup / Portfolio, 3. Analytics
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onShare(UserProfile profile) async {
    final profileType =
        profile.role == UserRole.entrepreneur ? 'founders' : 'investors';
    final realUrl = 'https://fikraty.app/$profileType/${profile.id}';

    await Clipboard.setData(ClipboardData(text: realUrl));

    setState(() {
      _shareNotice = 'Copied to clipboard: $realUrl';
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _shareNotice = null);
    });

    if (!mounted) return;
    _showShareBottomSheet(context, profile, realUrl);
  }

  void _showShareBottomSheet(
    BuildContext context,
    UserProfile profile,
    String realUrl,
  ) {
    bool linkCopied = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEntrepreneur = profile.role == UserRole.entrepreneur;
            final shareTitle =
                '${profile.fullName} | ${isEntrepreneur ? 'Founder' : 'Investor'} on Fikraty';

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Share Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 20, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: profile.photoUrl.isNotEmpty
                              ? CustomStartupImage(
                                  imagePath: profile.photoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      profile.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isEntrepreneur ? 'Founder' : 'Investor',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.title.isNotEmpty
                                    ? profile.title
                                    : (isEntrepreneur
                                        ? 'Founder & CEO'
                                        : 'Investor'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${profile.country.flagEmoji} ${profile.location}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            realUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await Clipboard.setData(
                                ClipboardData(text: realUrl));
                            setModalState(() => linkCopied = true);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Copied link: $realUrl'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: linkCopied
                                  ? AppColors.successLight
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  linkCopied ? Icons.check : Icons.copy,
                                  size: 13,
                                  color: linkCopied
                                      ? AppColors.successDark
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  linkCopied ? 'Copied' : 'Copy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: linkCopied
                                        ? AppColors.successDark
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Share via',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareChannel(
                        icon: Icons.copy,
                        label: 'Copy',
                        color: AppColors.primaryPurple,
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          await Clipboard.setData(ClipboardData(text: realUrl));
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Profile link copied: $realUrl'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareChannel(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          final msg =
                              'Check out $shareTitle on Fikraty: $realUrl';
                          await Clipboard.setData(ClipboardData(text: msg));
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content:
                                  Text('WhatsApp share text copied: $realUrl'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareChannel(
                        icon: Icons.work,
                        label: 'LinkedIn',
                        color: const Color(0xFF0077B5),
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          final msg =
                              'View ${profile.fullName}\'s profile on Fikraty: $realUrl';
                          await Clipboard.setData(ClipboardData(text: msg));
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content:
                                  Text('LinkedIn share text copied: $realUrl'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareChannel(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        color: const Color(0xFFEA4335),
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          final msg =
                              'Subject: ${profile.fullName}\'s Fikraty Profile\n\nLink: $realUrl';
                          await Clipboard.setData(ClipboardData(text: msg));
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Email share text copied: $realUrl'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShareChannel({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoadingState || state is ProfileInitialState) {
          return const Scaffold(
            backgroundColor: AppColors.grayBackground,
            body: LoadingWidget(message: 'Loading profile...'),
          );
        }

        if (state is ProfileErrorState) {
          return Scaffold(
            backgroundColor: AppColors.grayBackground,
            body: AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const LoadProfileEvent()),
            ),
          );
        }

        if (state is ProfileLoadedState) {
          final profile = state.profile;
          final isEntrepreneur = profile.role == UserRole.entrepreneur;

          return Scaffold(
            backgroundColor: AppColors.grayBackground,
            appBar: AppBar(
              title: Text(
                isEntrepreneur ? 'Founder Profile' : 'Investor Profile',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
              actions: [
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  onPressed: () => _confirmSignOut(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header: Cover, Avatar, Name, Country with Flag, Bio, Badges
                  ProfileHeader(
                    profile: profile,
                    shareNotice: _shareNotice,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileBloc>(),
                            child: const EditProfilePage(),
                          ),
                        ),
                      );
                    },
                    onShare: () => _onShare(profile),
                    onCountryChanged: (country) {
                      context
                          .read<ProfileBloc>()
                          .add(ChangeCountryEvent(country));
                    },
                  ),

                  // Stats row: Followers, Following, Investors Interested / Portfolio
                  ProfileStats(
                    profile: profile,
                    onInterestsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileBloc>(),
                            child: const InterestsPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Investor Thesis & Preferences Summary Card (if Investor)
                  if (!isEntrepreneur) ...[
                    BlocBuilder<InvestorPreferencesBloc,
                        InvestorPreferencesState>(
                      builder: (context, prefsState) {
                        final prefs = prefsState is InvestorPreferencesLoaded
                            ? prefsState.preferences
                            : null;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'INVESTMENT THESIS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '"${prefs?.investmentThesis.isNotEmpty == true ? prefs!.investmentThesis : profile.thesisQuote}"',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textBody,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context
                                            .read<InvestorPreferencesBloc>(),
                                        child:
                                            const InvestorPreferencesPage(),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: AppColors.cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'INVESTMENT PREFERENCES',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textMuted,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Edit Preferences →',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _PrefRow(
                                        label: 'Industries',
                                        value: prefs != null
                                            ? prefs.sectors.join(', ')
                                            : 'HealthTech, FinTech, SaaS',
                                      ),
                                      _PrefRow(
                                        label: 'Countries',
                                        value: prefs != null
                                            ? prefs.countries.join(', ')
                                            : 'Egypt, UAE, Saudi Arabia',
                                      ),
                                      _PrefRow(
                                        label: 'Stages',
                                        value: prefs != null
                                            ? prefs.stages.join(', ')
                                            : 'Seed, Series A',
                                      ),
                                      _PrefRow(
                                        label: 'Ticket size',
                                        value: prefs != null
                                            ? prefs.ticketSizeFormatted
                                            : '\$50K – \$500K',
                                        isLast: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3 Main Sections / Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) => setState(() {}),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2.5,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        const Tab(text: 'Posts'),
                        Tab(text: isEntrepreneur ? 'My Startup' : 'Portfolio'),
                        const Tab(text: 'Analytics'),
                      ],
                    ),
                  ),

                  // Tab Contents (Posts, Startup/Portfolio, Analytics)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: [
                      // Section 1: Posts
                      _buildPostsTab(profile),
                      // Section 2: Startup Profile / Portfolio
                      isEntrepreneur
                          ? _buildStartupTab(profile, context.read<AuthBloc>().state.user)
                          : _buildPortfolioTab(profile.portfolioStartups),
                      // Section 3: Analytics
                      _buildAnalyticsTab(profile, isEntrepreneur),
                    ][_tabController.index],
                  ),

                  // Workspace Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEntrepreneur
                              ? 'FOUNDER WORKSPACE'
                              : 'INVESTOR WORKSPACE',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (isEntrepreneur)
                          _buildFounderWorkspaceGrid(context, profile, context.read<AuthBloc>().state.user)
                        else
                          _buildInvestorWorkspaceGrid(context),

                        const SizedBox(height: 24),

                        // Account Settings Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                                child: Text(
                                  'ACCOUNT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const Divider(
                                  height: 1, color: AppColors.cardBorder),
                              _AccountRow(
                                title: '⚙️ Account & Privacy Settings',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<ProfileBloc>(),
                                        child: const SettingsPage(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _AccountRow(
                                title: '🚪 Sign Out',
                                textColor: AppColors.error,
                                isLast: true,
                                onTap: () => _confirmSignOut(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Founder Workspace
  Widget _buildFounderWorkspaceGrid(BuildContext context, UserProfile profile, auth.AuthUser? authUser) {
    final items = [
      {'label': '📊 Startup Analytics', 'icon': Icons.bar_chart_rounded},
      {'label': '👤 My Analytics', 'icon': Icons.person_outline_rounded},
      {'label': '🚀 Pitch Deck', 'icon': Icons.picture_as_pdf_outlined},
      {'label': '👥 Team Members', 'icon': Icons.groups_outlined},
      {'label': '🏆 Milestones', 'icon': Icons.flag_outlined},
      {'label': '🪄 Startup Wizard', 'icon': Icons.auto_awesome_outlined},
      {'label': '🛡️ Verification', 'icon': Icons.verified_user_outlined},
      {'label': '⚙️ Settings', 'icon': Icons.settings_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final label = item['label'] as String;
        final icon = item['icon'] as IconData;

        return InkWell(
          onTap: () {
            if (label == '⚙️ Settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: const SettingsPage(),
                  ),
                ),
              );
            } else if (label == '👤 My Analytics') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: const MyAnalyticsPage(),
                  ),
                ),
              );
            } else if (label == '📊 Startup Analytics') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StartupAnalyticsPage(),
                ),
              );
            } else if (label == '🚀 Pitch Deck') {
              _showPitchDeckModal(context, profile);
            } else if (label == '👥 Team Members') {
              _showManageTeamSheet(context, profile);
            } else if (label == '🏆 Milestones') {
              _showMilestonesModal(context);
            } else if (label == '🪄 Startup Wizard') {
              _openStartupWizard(profile, authUser);
            } else if (label == '🛡️ Verification') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubmitVerificationPage(
                    startup: _getStartupEntity(profile, authUser),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(height: 5),
                Text(
                  label.replaceAll(RegExp(r'[\u{1F300}-\u{1F6FF}]', unicode: true), '').trim(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Investor Workspace
  Widget _buildInvestorWorkspaceGrid(BuildContext context) {
    final items = [
      {'label': 'Preferences', 'icon': Icons.tune_rounded},
      {'label': 'My Analytics', 'icon': Icons.person_outline_rounded},
      {'label': 'Portfolio', 'icon': Icons.pie_chart_outline_rounded},
      {'label': 'Meetings', 'icon': Icons.calendar_month_outlined},
      {'label': 'Verification', 'icon': Icons.verified_user_outlined},
      {'label': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final label = item['label'] as String;
        final icon = item['icon'] as IconData;

        return InkWell(
          onTap: () {
            if (label == 'Preferences') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<InvestorPreferencesBloc>(),
                    child: const InvestorPreferencesPage(),
                  ),
                ),
              );
            } else if (label == 'My Analytics') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: const MyAnalyticsPage(),
                  ),
                ),
              );
            } else if (label == 'Portfolio') {
              _tabController.animateTo(1);
            } else if (label == 'Meetings') {
              _showMeetingsModal(context);
            } else if (label == 'Verification') {
              _showInvestorVerificationModal(context);
            } else if (label == 'Settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: const SettingsPage(),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section 1: Posts Tab
  Widget _buildPostsTab(UserProfile profile) {
    if (profile.posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: const [
            Icon(Icons.article_outlined, size: 44, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No Posts Published Yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Share updates, milestones, and thoughts directly from the Home community feed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
          ...profile.posts.map((post) {
            return InkWell(
              onTap: () {
                // Navigate to post detail
                final mappedPost = Post(
                  id: post.id,
                  authorUserId: int.tryParse(profile.id) ?? 1,
                  authorName: profile.fullName,
                  authorRole: profile.role == UserRole.entrepreneur
                      ? 'Founder'
                      : 'Investor',
                  authorAvatar: profile.photoUrl,
                  postType: PostType.update,
                  content: post.text,
                  createdAt: DateTime.now(),
                  likeCount: post.likes,
                  commentCount: 2,
                  isLiked: post.isLikedByMe,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(post: mappedPost),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          post.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            context
                                .read<ProfileBloc>()
                                .add(ToggleLikePostEvent(post.id));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  post.isLikedByMe
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: post.isLikedByMe
                                      ? AppColors.error
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.likes} likes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: post.isLikedByMe
                                        ? AppColors.error
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 14, color: AppColors.textMuted),
                            SizedBox(width: 4),
                            Text(
                              'Tap to view comments',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // Section 2: Startup Tab
  Widget _buildStartupTab(UserProfile profile, auth.AuthUser? authUser) {
    final startup = _getStartupEntity(profile, authUser);
    final bioText = startup.description.isNotEmpty
        ? startup.description
        : (startup.tagline.isNotEmpty
            ? startup.tagline
            : 'Building AI-powered diagnostics to make world-class healthcare accessible across MENA clinics.');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (startup.coverImageUrl != null && startup.coverImageUrl!.isNotEmpty)
                    CustomStartupImage(
                      imagePath: startup.coverImageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  // Dark overlay gradient for crisp text legibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Logo + Company Name & Industry
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (startup.logoUrl != null && startup.logoUrl!.isNotEmpty)
                                ? CustomStartupImage(
                                    imagePath: startup.logoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(Icons.rocket_launch_rounded,
                                        color: AppColors.primary, size: 24),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                startup.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ' ·  Venture',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFFE0E7FF),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Founded  · ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        startup.verificationStatus == 'verified' ? 'Verified Startup' : 'Registered Startup',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  bioText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Key metrics row
                Row(
                  children: [
                    _MetricBox(
                      label: 'MRR',
                      value: startup.monthlyRevenue.isNotEmpty
                          ? startup.monthlyRevenue
                          : r'.5K',
                    ),
                    const SizedBox(width: 8),
                    _MetricBox(
                      label: 'MoM Growth',
                      value: startup.growthRate.isNotEmpty
                          ? startup.growthRate
                          : '+34%',
                    ),
                    const SizedBox(width: 8),
                    _MetricBox(
                      label: 'Active Users',
                      value: startup.activeUsers.isNotEmpty
                          ? startup.activeUsers
                          : '1.2K Live',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pitch Deck Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            color: AppColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pitch Deck & Data Room',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              startup.targetRaise.isNotEmpty
                                  ? 'Target:  · '
                                  : '14 Slides · Updated 2026 · PDF',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showPitchDeckModal(context, profile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Problem & Solution
                _buildInfoBlock(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Problem & Value Proposition',
                  content: startup.problem.isNotEmpty
                      ? startup.problem
                      : 'Diagnostic bottlenecks and delay in lab turnaround cause treatment delays for millions across MENA clinics.',
                ),
                const SizedBox(height: 10),
                _buildInfoBlock(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Proprietary Solution',
                  content: startup.solution.isNotEmpty
                      ? startup.solution
                      : 'Real-time automated diagnostic interpretation engine that connects directly with clinic PACS in under 60 seconds.',
                ),
                if (startup.businessModel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoBlock(
                    icon: Icons.business_center_outlined,
                    title: 'Business Model',
                    content: startup.businessModel,
                  ),
                ],
                if (startup.targetMarket.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoBlock(
                    icon: Icons.groups_outlined,
                    title: 'Target Market',
                    content: startup.targetMarket,
                  ),
                ],
                const SizedBox(height: 16),

                // Team members summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Co-Founding Team',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showManageTeamSheet(context, profile),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Manage Team', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                _buildTeamMemberTile(
                  name: profile.fullName,
                  role: profile.title.isNotEmpty ? profile.title : 'CEO & Co-founder',
                  isMe: true,
                  isCofounder: true,
                ),
                ..._teamMembers.map((m) => _buildTeamMemberTile(
                      name: m.fullName,
                      role: m.roleTitle,
                      isMe: false,
                      isCofounder: m.isCofounder,
                      bio: m.bio,
                    )),
                const SizedBox(height: 16),
                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openStartupWizard(profile, authUser),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Edit Startup Wizard', style: TextStyle(fontSize: 11.5)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubmitVerificationPage(
                                startup: _getStartupEntity(profile, authUser),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_user_outlined, size: 16),
                        label: const Text('Legal Badge', style: TextStyle(fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 3: Analytics Tab
  Widget _buildAnalyticsTab(UserProfile profile, bool isEntrepreneur) {
    if (isEntrepreneur) {
      final founderCards = [
        {
          'label': 'Profile Views',
          'val': '2,840',
          'sub': '+18% this month',
          'icon': Icons.visibility_outlined,
          'color': 0xFF5548E8,
        },
        {
          'label': 'Investor Interest',
          'val': '${profile.investorInterestCount}',
          'sub': '+6 this week',
          'icon': Icons.swap_horiz,
          'color': 0xFF00C48C,
        },
        {
          'label': 'Pitch Deck Views',
          'val': '142',
          'sub': '+22 this month',
          'icon': Icons.picture_as_pdf_outlined,
          'color': 0xFFE8A020,
        },
        {
          'label': 'Post Engagement',
          'val': '${profile.totalLikes}',
          'sub': 'Likes across posts',
          'icon': Icons.favorite_border,
          'color': 0xFFE02424,
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: founderCards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final item = founderCards[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['label'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: Color(item['color'] as int),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['val'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['sub'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(item['color'] as int),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartupAnalyticsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.show_chart_rounded, size: 18),
                  label: const Text('Startup Analytics',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: const MyAnalyticsPage(),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.person_pin_rounded, size: 18),
                  label: const Text('My Analytics',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Investor Analytics view
      final investorCards = [
        {
          'label': 'Startups Evaluated',
          'val': '284',
          'sub': '+24 this month',
          'icon': Icons.search_rounded,
          'color': 0xFF5548E8,
        },
        {
          'label': 'Saved Startups',
          'val': '31',
          'sub': '+5 this month',
          'icon': Icons.bookmark_outline_rounded,
          'color': 0xFF00C48C,
        },
        {
          'label': 'Active Pipeline',
          'val': '4',
          'sub': 'In due diligence',
          'icon': Icons.trending_up_rounded,
          'color': 0xFFE8A020,
        },
        {
          'label': 'Meetings Held',
          'val': '12',
          'sub': '12 scheduled & completed',
          'icon': Icons.calendar_month_outlined,
          'color': 0xFF8B5CF6,
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: investorCards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final item = investorCards[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['label'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: Color(item['color'] as int),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['val'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['sub'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(item['color'] as int),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileBloc>(),
                      child: const MyAnalyticsPage(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.person_pin_rounded, size: 18),
              label: const Text('My Analytics',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }
  }

  // Portfolio tab for investor
  Widget _buildPortfolioTab(List<PortfolioStartup> portfolio) {
    return Column(
      children: portfolio.map((startup) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(startup.colorValue),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  startup.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  startup.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                startup.status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberTile({
    required String name,
    required String role,
    required bool isMe,
    bool isCofounder = false,
    String? bio,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'M',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ] else if (isCofounder) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Co-founder',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                if (bio != null && bio.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPitchDeckModal(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.companyName.isNotEmpty ? profile.companyName : 'NovaMed AI'} Pitch Deck',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Confidential Investor Presentation · Series Seed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        size: 40, color: AppColors.primary),
                    const SizedBox(height: 10),
                    const Text(
                      'Interactive Slide Viewer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Slide 1 of 14 · Executive Summary & Market Timing',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading pitch deck PDF (4.2 MB)...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onShare(profile);
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share Deck'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManageTeamSheet(BuildContext context, UserProfile profile) {
    final founderName = profile.fullName.isNotEmpty ? profile.fullName : 'Founder';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Team Members ()',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Add, edit, or remove your team members to maintain investor trust and up-to-date startup records.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Founder row (locked as 'You')
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                founderName.isNotEmpty ? founderName[0].toUpperCase() : 'Y',
                                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        founderName,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'You (Founder)',
                                          style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.title.isNotEmpty ? profile.title : 'CEO & Co-founder',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dynamic team members
                      if (_teamMembers.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Center(
                            child: Text(
                              'No additional team members added yet. Add co-founders or key team members below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                            ),
                          ),
                        )
                      else
                        ..._teamMembers.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final member = entry.value;
                          return StartupMemberTile(
                            member: member,
                            onEditPressed: () {
                              _showEditMemberDialog(context, idx, member, (updated) {
                                setSheetState(() {
                                  _teamMembers[idx] = updated;
                                });
                                setState(() {});
                              });
                            },
                            onDeletePressed: () {
                              setSheetState(() {
                                _teamMembers.removeAt(idx);
                              });
                              setState(() {});
                            },
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAddMemberDialog(context, (newMember) {
                        setSheetState(() {
                          _teamMembers.add(newMember);
                        });
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Team Member', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, void Function(StartupMemberEntity member) onAdd) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    bool isCofounder = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Team Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Title (e.g. CTO, CFO, Lead AI) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Experience / Background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Co-founder Role'),
                    value: isCofounder,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => isCofounder = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty || roleCtrl.text.trim().isEmpty) {
                        return;
                      }
                      onAdd(
                        StartupMemberEntity(
                          id: 'mem-',
                          fullName: nameCtrl.text.trim(),
                          roleTitle: roleCtrl.text.trim(),
                          isCofounder: isCofounder,
                          bio: bioCtrl.text.trim().isNotEmpty ? bioCtrl.text.trim() : null,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Member',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditMemberDialog(
    BuildContext context,
    int index,
    StartupMemberEntity member,
    void Function(StartupMemberEntity updated) onSave,
  ) {
    final nameCtrl = TextEditingController(text: member.fullName);
    final roleCtrl = TextEditingController(text: member.roleTitle);
    final bioCtrl = TextEditingController(text: member.bio ?? '');
    bool isCofounder = member.isCofounder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Team Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Title (e.g. CTO, CFO, Lead AI) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Experience / Background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Co-founder Role'),
                    value: isCofounder,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => isCofounder = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty || roleCtrl.text.trim().isEmpty) {
                        return;
                      }
                      onSave(
                        member.copyWith(
                          fullName: nameCtrl.text.trim(),
                          roleTitle: roleCtrl.text.trim(),
                          isCofounder: isCofounder,
                          bio: bioCtrl.text.trim().isNotEmpty ? bioCtrl.text.trim() : null,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Member',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMilestonesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Startup Milestones & Roadmap',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Text(
                    'Track execution progress to provide investors with clear proof of momentum.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ..._milestones.map((m) {
                    final bool isDone = (m['done'] as bool?) ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFF0FDF4) : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDone ? const Color(0xFF86EFAC) : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: isDone ? AppColors.successDark : AppColors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text(
                                  m['date'] as String,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDone,
                            activeThumbColor: AppColors.successDark,
                            onChanged: (val) {
                              setSheetState(() {
                                m['done'] = val;
                              });
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save & Done', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMeetingsModal(BuildContext context) {
    final meetings = [
      {'startup': 'NovaMed AI', 'time': 'Tomorrow, 2:00 PM', 'topic': 'Pitch & Q&A (Series Seed)'},
      {'startup': 'Payra', 'time': 'Thursday, 4:30 PM', 'topic': 'Follow-up Term Sheet Discussion'},
      {'startup': 'CargoLinx', 'time': 'Next Monday, 11:00 AM', 'topic': 'Introductory Founder Call'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Founder Meetings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...meetings.map(
              (m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['startup']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text(m['topic']!,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textSecondary)),
                          Text(m['time']!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
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

  void _showInvestorVerificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: AppColors.successDark, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Accredited Investor Status',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Your profile is verified as an active accredited venture investor on Fikraty with complete access to startup data rooms.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Accreditation Status',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('Verified (Tier 1)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StartupEntity _getStartupEntity(UserProfile profile, auth.AuthUser? authUser) {
    if (_startup != null) {
      return _startup!.copyWith(members: List<StartupMemberEntity>.from(_teamMembers));
    }
    final st = authUser?.startup;
    _startup = StartupEntity(
      id: profile.id,
      ownerUserId: profile.id,
      name: (st?.name.isNotEmpty == true)
          ? st!.name
          : (profile.companyName.isNotEmpty ? profile.companyName : 'NovaMed AI'),
      tagline: (st?.tagline?.isNotEmpty == true)
          ? st!.tagline!
          : 'AI-driven diagnostics for MENA clinics',
      description: (st?.description?.isNotEmpty == true)
          ? st!.description!
          : (profile.bio.isNotEmpty
              ? profile.bio
              : 'Building AI-powered diagnostics to make healthcare accessible across MENA clinics.'),
      problem: (st?.problem?.isNotEmpty == true)
          ? st!.problem!
          : 'Diagnostic bottlenecks and delay in lab turnaround cause treatment delays for millions across MENA clinics.',
      solution: (st?.solution?.isNotEmpty == true)
          ? st!.solution!
          : 'Real-time automated diagnostic interpretation engine connecting to clinic PACS in under 60 seconds.',
      businessModel: (st?.businessModel?.isNotEmpty == true)
          ? st!.businessModel!
          : 'B2B SaaS subscription with tier-based pricing',
      targetMarket: (st?.targetMarket?.isNotEmpty == true)
          ? st!.targetMarket!
          : '3,800 private clinics across Egypt and GCC',
      industryName: (st?.industry.label.isNotEmpty == true)
          ? st!.industry.label
          : (profile.industry.isNotEmpty ? profile.industry : 'HealthTech'),
      stageName: (st?.stage.label.isNotEmpty == true)
          ? st!.stage.label
          : (profile.companyStage.isNotEmpty ? profile.companyStage : 'Seed'),
      cityName: (st?.cityCode?.isNotEmpty == true)
          ? st!.cityCode!
          : (profile.location.isNotEmpty ? profile.location : 'Cairo, Egypt'),
      websiteUrl: (st?.websiteUrl?.isNotEmpty == true && st!.websiteUrl != 'https://')
          ? st.websiteUrl!
          : (profile.website.isNotEmpty
              ? (profile.website.startsWith('http')
                  ? profile.website
                  : 'https://${profile.website}')
              : ''),
      demoUrl: st?.demoUrl ?? '',
      foundedYear: st?.foundedYear ?? 2024,
      logoUrl: profile.photoUrl.isNotEmpty
          ? profile.photoUrl
          : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200',
      coverImageUrl: profile.coverUrl.isNotEmpty
          ? profile.coverUrl
          : 'https://images.unsplash.com/photo-1557683316-973673baf926?w=1000',
      targetRaise: r',000',
      fundingRound: 'Seed Round',
      minTicket: r',000',
      valuationCap: r',500,000',
      growthRate: '+34% MoM',
      activeUsers: '1.2K Live',
      monthlyRevenue: r'.5K/mo',
      members: List<StartupMemberEntity>.from(_teamMembers),
    );
    return _startup!;
  }

  Future<void> _openStartupWizard(UserProfile profile, auth.AuthUser? authUser) async {
    final currentStartup = _getStartupEntity(profile, authUser);
    final updatedStartup = await Navigator.push<StartupEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => StartupsBloc(repository: StartupsRepositoryImpl()),
          child: StartupWizardPage(
            initialStartup: currentStartup,
          ),
        ),
      ),
    );

    if (updatedStartup != null && mounted) {
      setState(() {
        _startup = updatedStartup;
        _teamMembers
          ..clear()
          ..addAll(updatedStartup.members);
      });
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          profile.copyWith(
            companyName: updatedStartup.name,
            industry: updatedStartup.industryName,
            companyStage: updatedStartup.stageName,
            bio: updatedStartup.description.isNotEmpty ? updatedStartup.description : profile.bio,
            location: updatedStartup.cityName.isNotEmpty ? updatedStartup.cityName : profile.location,
            website: updatedStartup.websiteUrl ?? profile.website,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Startup profile and details updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _PrefRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final bool isLast;

  const _AccountRow({
    required this.title,
    required this.onTap,
    this.textColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textMuted,
          ),
          dense: true,
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.cardBorder),
      ],
    );
  }
}
