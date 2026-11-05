import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/post.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../explore/presentation/bloc/explore_bloc.dart';
import '../../../explore/presentation/bloc/explore_event.dart';

class InvestorDetailScreen extends StatefulWidget {
  final RecommendedInvestor? investor;

  const InvestorDetailScreen({
    super.key,
    this.investor,
  });

  @override
  State<InvestorDetailScreen> createState() => _InvestorDetailScreenState();
}

class _InvestorDetailScreenState extends State<InvestorDetailScreen> {
  bool _isFollowing = false;
  bool _isBookmarked = false;

  late final RecommendedInvestor _investor;

  String get _safeName => _investor.name.toLowerCase().replaceAll(' ', '_');
  String get _followPrefKey => 'investor_following_$_safeName';
  String get _bookmarkPrefKey => 'investor_bookmarked_$_safeName';

  @override
  void initState() {
    super.initState();
    _investor = widget.investor ??
        const RecommendedInvestor(
          id: 101,
          name: 'Omar Khalil',
          role: 'Principal · Wamda Capital',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          matchPercentage: 92,
        );
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isFollowing = prefs.getBool(_followPrefKey) ?? false;
          _isBookmarked = prefs.getBool(_bookmarkPrefKey) ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    final nextFollowing = !_isFollowing;
    setState(() {
      _isFollowing = nextFollowing;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_followPrefKey, nextFollowing);
    } catch (_) {}

    if (mounted) {
      try {
        context.read<ExploreBloc>().add(
              ToggleFollowEvent(type: 'investor', id: _investor.id),
            );
      } catch (_) {}

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextFollowing
                ? 'You are now following ${_investor.name}'
                : 'Unfollowed ${_investor.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    final nextBookmarked = !_isBookmarked;
    setState(() {
      _isBookmarked = nextBookmarked;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_bookmarkPrefKey, nextBookmarked);
    } catch (_) {}

    if (mounted) {
      try {
        context.read<ExploreBloc>().add(
              ToggleBookmarkEvent(type: 'investor', id: _investor.id),
            );
      } catch (_) {}

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextBookmarked ? 'Saved to Bookmarks' : 'Removed from Bookmarks',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _investor.name,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.primaryPurple : AppColors.ink,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.ink, size: 21),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile link for ${_investor.name} copied to clipboard!'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Profile Header Card
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  // Top Gradient Banner
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.violetText],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Avatar & Identity
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Avatar with border
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    _investor.avatarUrl,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const CircleAvatar(
                                      radius: 42,
                                      backgroundColor: AppColors.purpleLight,
                                      child: Icon(Icons.person,
                                          size: 42, color: AppColors.primaryPurple),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Name & Verified Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _investor.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.blueBright,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Role & Firm
                          Text(
                            _investor.role,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Location Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textMuted),
                              SizedBox(width: 4),
                              Text(
                                'Dubai, UAE · Active MENA Investor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Compatibility Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.mintSoft),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_investor.matchPercentage}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'High Investment Compatibility',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.emeraldDarkest,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Matches your startup stage, industry sector, and funding target.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.emeraldDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Action Buttons: Message & Follow
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatDetailPage(
                                          userName: _investor.name,
                                          userAvatar: _investor.avatarUrl,
                                          isOnline: true,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                                      size: 16),
                                  label: const Text('Message'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _toggleFollow,
                                  icon: Icon(
                                    _isFollowing
                                        ? Icons.check_rounded
                                        : Icons.person_add_outlined,
                                    size: 16,
                                  ),
                                  label: Text(_isFollowing ? 'Following' : 'Follow'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isFollowing
                                        ? AppColors.primaryPurple.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    foregroundColor: AppColors.primaryPurple,
                                    side: const BorderSide(
                                        color: AppColors.primaryPurple, width: 1.5),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Investment Thesis Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Investment Thesis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grayBg,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: AppColors.primaryPurple, width: 3),
                        ),
                      ),
                      child: Text(
                        '"We back early-stage founders transforming foundational industries across MENA. We prioritize solid unit economics, exceptional engineering talent, and defensible tech moats."',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Investment Criteria Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Investment Criteria',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCriteriaTile(
                            icon: Icons.monetization_on_outlined,
                            label: 'Ticket Size',
                            value: '\$50K - \$250K',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCriteriaTile(
                            icon: Icons.layers_outlined,
                            label: 'Stage',
                            value: 'Seed & Pre-Seed',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCriteriaTile(
                            icon: Icons.public_rounded,
                            label: 'Geography',
                            value: 'MENA & GCC',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCriteriaTile(
                            icon: Icons.pie_chart_outline_rounded,
                            label: 'Portfolio Size',
                            value: '18+ Startups',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sectors of Interest
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sectors of Interest',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'HealthTech',
                        'FinTech',
                        'Artificial Intelligence',
                        'B2B SaaS',
                        'CleanTech & Energy',
                        'Logistics',
                      ].map((sector) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.borderSubtle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            sector,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Backed Startups Portfolio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sample Backed Startups',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPortfolioStartupTile(
                      name: 'FikraPay',
                      sector: 'FinTech · Seed',
                      description: 'Instant B2B payment rails for SMEs in Egypt.',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.purpleGlow,
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    _buildPortfolioStartupTile(
                      name: 'SehaCloud',
                      sector: 'HealthTech · Pre-Seed',
                      description: 'EMR and AI diagnostic interpretation engine.',
                      icon: Icons.health_and_safety_rounded,
                      color: AppColors.success,
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    _buildPortfolioStartupTile(
                      name: 'AgriSense',
                      sector: 'CleanTech · Seed',
                      description: 'Precision irrigation sensors for commercial farms.',
                      icon: Icons.eco_rounded,
                      color: AppColors.emeraldText,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryPurple),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStartupTile({
    required String name,
    required String sector,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sector,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
