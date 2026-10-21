import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/countries.dart';
import '../../../auth/domain/entities/auth.dart' as auth;
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/interest_item.dart';
import '../models/user_profile_model.dart';
import '../models/investor_preferences_model.dart';
import '../models/interest_item_model.dart';

abstract class ProfileDataSource {
  Future<UserProfileModel> getProfile({UserRole? role});
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<UserProfileModel> switchRole(UserRole newRole);
  Future<UserProfileModel> updateUserCountry(Country country);
  Future<UserProfileModel> addPost(String text);
  Future<UserProfileModel> togglePostLike(int postId);
  Future<UserProfileModel> uploadDocument(ProfileDocument document);
  Future<UserProfileModel> removeDocument(String documentId);
  Future<InvestorPreferencesModel> getInvestorPreferences();
  Future<InvestorPreferencesModel> updateInvestorPreferences(
      InvestorPreferencesModel preferences);
  Future<List<InterestItemModel>> getInterests({
    required UserRole role,
    required InterestDirection direction,
  });
  Future<InterestItemModel> updateInterestStatus({
    required int interestId,
    required InterestStatus newStatus,
  });
}

class ProfileDummyDataSource implements ProfileDataSource {
  UserRole _currentRole = UserRole.entrepreneur;
  final auth.AuthUser? authUser;

  late UserProfileModel _entrepreneurProfile;
  late UserProfileModel _investorProfile;
  late InvestorPreferencesModel _investorPreferences;
  late List<InterestItemModel> _interests;

  static const String _keyEntrepreneur = 'fikraty_profile_entrepreneur';
  static const String _keyInvestor = 'fikraty_profile_investor';
  static const String _keyPreferences = 'fikraty_investor_preferences';
  static const String _keyInterests = 'fikraty_interests';

  ProfileDummyDataSource({this.authUser}) {
    if (authUser?.role == auth.UserRole.investor) {
      _currentRole = UserRole.investor;
    } else {
      _currentRole = UserRole.entrepreneur;
    }
    _initDefaultData();
    _loadFromPersistence();
  }

  void _initDefaultData() {
    final String entName = (authUser?.profile.fullName.isNotEmpty == true)
        ? authUser!.profile.fullName
        : 'Sarah Al-Mansouri';
    final String entCompany = (authUser?.startup?.name.isNotEmpty == true)
        ? authUser!.startup!.name
        : 'NovaMed AI';
    final String entLocation = (authUser?.profile.location?.isNotEmpty == true)
        ? authUser!.profile.location!
        : (authUser?.profile.cityCode?.isNotEmpty == true
            ? authUser!.profile.cityCode!
            : 'Cairo, Egypt');
    final String entBio = (authUser?.profile.bio?.isNotEmpty == true)
        ? authUser!.profile.bio!
        : (authUser?.startup?.description?.isNotEmpty == true
            ? authUser!.startup!.description!
            : 'Building AI-powered diagnostics to make world-class healthcare accessible to underserved clinics across MENA.');
    final String entTitle = (authUser?.profile.professionalTitle?.isNotEmpty == true)
        ? authUser!.profile.professionalTitle!
        : 'Founder & CEO';
    final String entEmail = (authUser?.email.isNotEmpty == true)
        ? authUser!.email
        : 'sarah@novamed.ai';
    final String entPhone = (authUser?.phone?.isNotEmpty == true)
        ? authUser!.phone!
        : '+971 50 123 4567';
    final String entIndustry = (authUser?.startup?.industry.label.isNotEmpty == true)
        ? authUser!.startup!.industry.label
        : 'HealthTech';
    final String entStage = (authUser?.startup?.stage.label.isNotEmpty == true)
        ? authUser!.startup!.stage.label
        : 'Seed';

    _entrepreneurProfile = UserProfileModel(
      id: authUser?.id ?? '1',
      role: UserRole.entrepreneur,
      fullName: entName,
      title: entTitle,
      companyName: entCompany,
      bio: entBio,
      background: 'Stanford Medicine Research Fellow',
      location: entLocation,
      country: AppCountries.findByCode('EG'),
      photoUrl:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&auto=format',
      coverUrl: '',
      website: authUser?.startup?.websiteUrl ?? 'novamed.ai',
      linkedIn: authUser?.profile.linkedinUrl ?? 'linkedin.com/in/sarah-almansouri',
      twitter: authUser?.profile.twitterUrl ?? '@sarah_novamed',
      angelList: 'angel.co/sarah-almansouri',
      expertise: authUser?.profile.expertise.isNotEmpty == true
          ? authUser!.profile.expertise
          : const ['AI/ML', 'HealthTech', 'Fundraising', 'B2B SaaS'],
      industry: entIndustry,
      companyStage: entStage,
      isVerified: true,
      verificationBadge: 'Verified Founder',
      followersCount: 1240,
      followingCount: 348,
      investorInterestCount: 47,
      profileViews: 2840,
      email: entEmail,
      phone: entPhone,
      profileVisibility: 'Public',
      messagingFrom: 'Everyone',
      posts: const [
        UserPost(
          id: 1,
          text:
              'Thrilled to announce NovaMed AI has just closed our Seed round — \$2.4M led by Sequoia Arabia with participation from regional angels! Onwards to revolutionizing diagnostics across MENA clinics.',
          likes: 284,
          time: '2h ago',
          isLikedByMe: false,
        ),
        UserPost(
          id: 2,
          text:
              'Month 3 update: we onboarded our first 10 clinics across UAE and Egypt. The AI model accuracy reached 98.4% on diagnostic scans.',
          likes: 156,
          time: '2w ago',
          isLikedByMe: false,
        ),
      ],
      portfolioStartups: const [],
      documents: const [
        ProfileDocument(
          id: 'doc_1',
          name: 'NovaMed_Commercial_Register.pdf',
          size: '1.4 MB',
          uploadDate: 'Sep 10, 2026',
          path: '',
          type: 'pdf',
        ),
        ProfileDocument(
          id: 'doc_2',
          name: 'NovaMed_Pitch_Deck_Q3.pdf',
          size: '4.8 MB',
          uploadDate: 'Sep 15, 2026',
          path: '',
          type: 'pdf',
        ),
      ],
    );

    final String invName = (authUser?.profile.fullName.isNotEmpty == true)
        ? authUser!.profile.fullName
        : 'Omar Khalil';
    final String invFirm = (authUser?.investor?.firmName?.isNotEmpty == true)
        ? authUser!.investor!.firmName!
        : 'Wamda Capital';
    final String invLocation = (authUser?.profile.location?.isNotEmpty == true)
        ? authUser!.profile.location!
        : (authUser?.profile.cityCode?.isNotEmpty == true
            ? authUser!.profile.cityCode!
            : 'Dubai, UAE');
    final String invBio = (authUser?.profile.bio?.isNotEmpty == true)
        ? authUser!.profile.bio!
        : 'Principal at Wamda Capital. 10+ years investing in MENA tech. Former founder (exited 2018). Backing the next generation of ambitious MENA builders.';
    final String invTitle = (authUser?.profile.professionalTitle?.isNotEmpty == true)
        ? authUser!.profile.professionalTitle!
        : 'Principal · $invFirm';
    final String invEmail = (authUser?.email.isNotEmpty == true)
        ? authUser!.email
        : 'omar@wamdacapital.com';
    final String invPhone = (authUser?.phone?.isNotEmpty == true)
        ? authUser!.phone!
        : '+971 50 987 6543';
    final String invThesis = (authUser?.investor?.thesis?.isNotEmpty == true)
        ? authUser!.investor!.thesis!
        : 'I back founders who deeply understand their market and build with capital efficiency.';

    _investorProfile = UserProfileModel(
      id: authUser?.id ?? '2',
      role: UserRole.investor,
      fullName: invName,
      title: invTitle,
      companyName: invFirm,
      firmName: invFirm,
      fundSize: '50M',
      yearsInvesting: '10',
      bio: invBio,
      background: 'Former founder, exited fintech startup in 2018',
      location: invLocation,
      country: AppCountries.findByCode('AE'),
      photoUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&auto=format',
      coverUrl: '',
      website: authUser?.profile.websiteUrl ?? 'wamdacapital.com',
      linkedIn: authUser?.profile.linkedinUrl ?? 'linkedin.com/in/omarkhalil',
      twitter: authUser?.profile.twitterUrl ?? '@omar_khalil_vc',
      angelList: 'angel.co/omar-khalil',
      expertise: authUser?.profile.expertise.isNotEmpty == true
          ? authUser!.profile.expertise
          : const ['FinTech', 'HealthTech', 'SaaS', 'B2B', 'AI/ML'],
      isVerified: true,
      verificationBadge: 'Verified Investor',
      followersCount: 3400,
      followingCount: 520,
      investorInterestCount: 12,
      portfolioCount: 4,
      totalDeployed: '\$28M',
      thesisQuote: invThesis,
      profileViews: 1950,
      email: invEmail,
      phone: invPhone,
      profileVisibility: 'Public',
      messagingFrom: 'Everyone',
      posts: const [
        UserPost(
          id: 101,
          text:
              'What I look for in a founder pitch: clarity of problem, size of opportunity, and undeniable unfair advantage. Execution beats hype every time.',
          likes: 512,
          time: '4h ago',
          isLikedByMe: false,
        ),
        UserPost(
          id: 102,
          text:
              'Proud to lead NovaMed AI\'s Seed round. This team is solving a real problem at scale in healthcare diagnostics. Watch this space.',
          likes: 243,
          time: '3d ago',
          isLikedByMe: false,
        ),
      ],
      portfolioStartups: const [
        PortfolioStartup(
          id: 1,
          name: 'NovaMed AI',
          sector: 'HealthTech',
          status: 'Active',
          initials: 'No',
          colorValue: 0xFF5548E8,
        ),
        PortfolioStartup(
          id: 2,
          name: 'Payra',
          sector: 'FinTech',
          status: 'Active',
          initials: 'Pa',
          colorValue: 0xFF8B5CF6,
        ),
        PortfolioStartup(
          id: 3,
          name: 'TechBridge',
          sector: 'B2B SaaS',
          status: 'Active',
          initials: 'Te',
          colorValue: 0xFF0EA5E9,
        ),
        PortfolioStartup(
          id: 4,
          name: 'CargoLinx',
          sector: 'Logistics',
          status: 'Active',
          initials: 'Ca',
          colorValue: 0xFF00C48C,
        ),
      ],
      documents: const [
        ProfileDocument(
          id: 'doc_inv_1',
          name: 'Fund_II_Accreditation.pdf',
          size: '2.1 MB',
          uploadDate: 'Aug 20, 2026',
          path: '',
          type: 'pdf',
        ),
      ],
    );

    final invPrefsSectors = (authUser?.investor != null && authUser!.investor!.preferredIndustries.isNotEmpty)
        ? authUser!.investor!.preferredIndustries.map((e) => e.label).toList()
        : const ['HealthTech', 'FinTech', 'AI / ML', 'SaaS'];
    final invPrefsStages = (authUser?.investor != null && authUser!.investor!.preferredStages.isNotEmpty)
        ? authUser!.investor!.preferredStages.map((e) => e.label).toList()
        : const ['Seed', 'Series A'];
    final invPrefsCountries = (authUser?.investor != null && authUser!.investor!.preferredCountries.isNotEmpty)
        ? authUser!.investor!.preferredCountries.map((e) => e.label).toList()
        : const ['Egypt', 'UAE', 'Saudi Arabia'];

    _investorPreferences = InvestorPreferencesModel(
      sectors: invPrefsSectors,
      stages: invPrefsStages,
      countries: invPrefsCountries,
      ticketMin: authUser?.investor?.ticketMin != null ? '\$${authUser!.investor!.ticketMin!.toInt()}K' : '\$50K',
      ticketMax: authUser?.investor?.ticketMax != null ? '\$${authUser!.investor!.ticketMax!.toInt()}K' : '\$500K',
      dealTypes: const ['Equity', 'SAFE'],
      investmentThesis: invThesis,
      openToCoInvesting: true,
      advisoryRoles: true,
      boardSeats: false,
      notifyMatches: true,
      notifyMessages: true,
      isCompleted: true,
    );

    _interests = [
      const InterestItemModel(
        id: 1,
        name: 'Layla Al-Rashid',
        organization: 'Wamda Capital',
        amount: '\$150K',
        stage: 'Seed',
        sector: 'HealthTech',
        date: 'Sep 18, 2026',
        matchPercentage: 94,
        initials: 'LR',
        colorValue: 0xFF5548E8,
        direction: InterestDirection.received,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 2,
        name: 'Marcus Chen',
        organization: 'BECO Capital',
        amount: '\$250K',
        stage: 'Seed',
        sector: 'AI / ML',
        date: 'Sep 15, 2026',
        matchPercentage: 88,
        initials: 'MC',
        colorValue: 0xFF00C48C,
        direction: InterestDirection.received,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 3,
        name: 'Fatima Zahra',
        organization: 'Algebra Ventures',
        amount: '\$100K',
        stage: 'Pre-Seed',
        sector: 'HealthTech',
        date: 'Sep 12, 2026',
        matchPercentage: 82,
        initials: 'FZ',
        colorValue: 0xFFE85548,
        direction: InterestDirection.received,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 4,
        name: 'Omar Khalil',
        organization: 'Global Ventures',
        amount: '\$500K',
        stage: 'Series A',
        sector: 'Deep Tech',
        date: 'Sep 10, 2026',
        matchPercentage: 76,
        initials: 'OK',
        colorValue: 0xFFE8A020,
        direction: InterestDirection.received,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 101,
        name: 'GreenStack',
        organization: 'GreenStack Inc.',
        amount: '\$200K',
        stage: 'Seed',
        sector: 'CleanTech',
        date: 'Sep 20, 2026',
        initials: 'GS',
        colorValue: 0xFF00C48C,
        direction: InterestDirection.sent,
        status: InterestStatus.accepted,
      ),
      const InterestItemModel(
        id: 102,
        name: 'FinBridge',
        organization: 'FinBridge Labs',
        amount: '\$75K',
        stage: 'Pre-Seed',
        sector: 'FinTech',
        date: 'Sep 17, 2026',
        initials: 'FB',
        colorValue: 0xFF5548E8,
        direction: InterestDirection.sent,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 103,
        name: 'LogiRoute',
        organization: 'LogiRoute MENA',
        amount: '\$120K',
        stage: 'Seed',
        sector: 'Logistics',
        date: 'Sep 14, 2026',
        initials: 'LR',
        colorValue: 0xFFE85548,
        direction: InterestDirection.sent,
        status: InterestStatus.declined,
      ),
      const InterestItemModel(
        id: 201,
        name: 'NovaMed AI',
        organization: 'NovaMed AI',
        amount: '\$100K',
        stage: 'Seed',
        sector: 'HealthTech',
        date: 'Sep 21, 2026',
        initials: 'NM',
        colorValue: 0xFF5548E8,
        direction: InterestDirection.received,
        status: InterestStatus.accepted,
      ),
      const InterestItemModel(
        id: 202,
        name: 'EduSync',
        organization: 'EduSync Arabia',
        amount: '\$50K',
        stage: 'Pre-Seed',
        sector: 'EdTech',
        date: 'Sep 19, 2026',
        initials: 'ES',
        colorValue: 0xFF00C48C,
        direction: InterestDirection.received,
        status: InterestStatus.pending,
      ),
      const InterestItemModel(
        id: 301,
        name: 'NovaMed AI',
        organization: 'NovaMed AI',
        amount: '\$150K',
        stage: 'Seed',
        sector: 'HealthTech',
        date: 'Sep 20, 2026',
        initials: 'NM',
        colorValue: 0xFF5548E8,
        direction: InterestDirection.sent,
        status: InterestStatus.accepted,
      ),
    ];
  }

  Future<void> _loadFromPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final entJson = prefs.getString(_keyEntrepreneur);
      if (entJson != null) {
        _entrepreneurProfile =
            UserProfileModel.fromMap(jsonDecode(entJson) as Map<String, dynamic>);
      }

      final invJson = prefs.getString(_keyInvestor);
      if (invJson != null) {
        _investorProfile =
            UserProfileModel.fromMap(jsonDecode(invJson) as Map<String, dynamic>);
      }

      final prefJson = prefs.getString(_keyPreferences);
      if (prefJson != null) {
        _investorPreferences = InvestorPreferencesModel.fromMap(
            jsonDecode(prefJson) as Map<String, dynamic>);
      }

      final interestsJson = prefs.getString(_keyInterests);
      if (interestsJson != null) {
        final List<dynamic> list = jsonDecode(interestsJson) as List<dynamic>;
        _interests = list
            .map((e) => InterestItemModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      if (authUser != null) {
        if (authUser!.role == auth.UserRole.entrepreneur) {
          _entrepreneurProfile = UserProfileModel.fromEntity(_entrepreneurProfile.copyWith(
            id: authUser!.id,
            fullName: authUser!.profile.fullName.isNotEmpty
                ? authUser!.profile.fullName
                : _entrepreneurProfile.fullName,
            email: authUser!.email.isNotEmpty ? authUser!.email : _entrepreneurProfile.email,
            phone: authUser!.phone ?? _entrepreneurProfile.phone,
            companyName: authUser!.startup?.name.isNotEmpty == true
                ? authUser!.startup!.name
                : _entrepreneurProfile.companyName,
            title: authUser!.profile.professionalTitle ?? _entrepreneurProfile.title,
            bio: authUser!.profile.bio ?? _entrepreneurProfile.bio,
            location: authUser!.profile.location ?? _entrepreneurProfile.location,
            industry: authUser!.startup?.industry.label ?? _entrepreneurProfile.industry,
            companyStage: authUser!.startup?.stage.label ?? _entrepreneurProfile.companyStage,
          ));
        } else {
          _investorProfile = UserProfileModel.fromEntity(_investorProfile.copyWith(
            id: authUser!.id,
            fullName: authUser!.profile.fullName.isNotEmpty
                ? authUser!.profile.fullName
                : _investorProfile.fullName,
            email: authUser!.email.isNotEmpty ? authUser!.email : _investorProfile.email,
            phone: authUser!.phone ?? _investorProfile.phone,
            firmName: authUser!.investor?.firmName ?? _investorProfile.firmName,
            companyName: authUser!.investor?.firmName ?? _investorProfile.companyName,
            title: authUser!.profile.professionalTitle ?? _investorProfile.title,
            bio: authUser!.profile.bio ?? _investorProfile.bio,
            location: authUser!.profile.location ?? _investorProfile.location,
            thesisQuote: authUser!.investor?.thesis ?? _investorProfile.thesisQuote,
          ));
        }
      }
    } catch (_) {
      // Graceful fallback to default in-memory state
    }
  }

  Future<void> _saveToPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyEntrepreneur, jsonEncode(_entrepreneurProfile.toMap()));
      await prefs.setString(
          _keyInvestor, jsonEncode(_investorProfile.toMap()));
      await prefs.setString(
          _keyPreferences, jsonEncode(_investorPreferences.toMap()));
      await prefs.setString(
          _keyInterests,
          jsonEncode(_interests.map((e) => e.toMap()).toList()));
    } catch (_) {}
  }

  @override
  Future<UserProfileModel> getProfile({UserRole? role}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final targetRole = role ?? _currentRole;
    return targetRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (profile.role == UserRole.entrepreneur) {
      _entrepreneurProfile = profile;
    } else {
      _investorProfile = profile;
    }
    await _saveToPersistence();
    return profile;
  }

  @override
  Future<UserProfileModel> switchRole(UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentRole = newRole;
    return getProfile(role: newRole);
  }

  @override
  Future<UserProfileModel> updateUserCountry(Country country) async {
    final active = _currentRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;

    final updated = UserProfileModel.fromEntity(
      active.copyWith(
        country: country,
        location: '${active.location.split(',').first.trim()}, ${country.name}',
      ),
    );
    return updateProfile(updated);
  }

  @override
  Future<UserProfileModel> addPost(String text) async {
    final active = _currentRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;

    final newPost = UserPost(
      id: DateTime.now().millisecondsSinceEpoch,
      text: text,
      likes: 0,
      time: 'Just now',
      isLikedByMe: false,
    );

    final updatedPosts = [newPost, ...active.posts];
    final updated = UserProfileModel.fromEntity(
      active.copyWith(posts: updatedPosts),
    );
    return updateProfile(updated);
  }

  @override
  Future<UserProfileModel> togglePostLike(int postId) async {
    final active = _currentRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;

    final updatedPosts = active.posts.map((post) {
      if (post.id == postId) {
        final isLiked = !post.isLikedByMe;
        final newLikes = isLiked ? post.likes + 1 : (post.likes > 0 ? post.likes - 1 : 0);
        return post.copyWith(isLikedByMe: isLiked, likes: newLikes);
      }
      return post;
    }).toList();

    final updated = UserProfileModel.fromEntity(
      active.copyWith(posts: updatedPosts),
    );
    return updateProfile(updated);
  }

  @override
  Future<UserProfileModel> uploadDocument(ProfileDocument document) async {
    final active = _currentRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;

    final updatedDocs = [document, ...active.documents];
    final updated = UserProfileModel.fromEntity(
      active.copyWith(documents: updatedDocs),
    );
    return updateProfile(updated);
  }

  @override
  Future<UserProfileModel> removeDocument(String documentId) async {
    final active = _currentRole == UserRole.entrepreneur
        ? _entrepreneurProfile
        : _investorProfile;

    final updatedDocs =
        active.documents.where((d) => d.id != documentId).toList();
    final updated = UserProfileModel.fromEntity(
      active.copyWith(documents: updatedDocs),
    );
    return updateProfile(updated);
  }

  @override
  Future<InvestorPreferencesModel> getInvestorPreferences() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _investorPreferences;
  }

  @override
  Future<InvestorPreferencesModel> updateInvestorPreferences(
      InvestorPreferencesModel preferences) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _investorPreferences = preferences;
    await _saveToPersistence();
    return _investorPreferences;
  }

  @override
  Future<List<InterestItemModel>> getInterests({
    required UserRole role,
    required InterestDirection direction,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (role == UserRole.entrepreneur) {
      return _interests
          .where((i) =>
              (direction == InterestDirection.received && i.id < 100) ||
              (direction == InterestDirection.sent &&
                  i.id >= 100 &&
                  i.id < 200))
          .toList();
    } else {
      return _interests
          .where((i) =>
              (direction == InterestDirection.received &&
                  i.id >= 200 &&
                  i.id < 300) ||
              (direction == InterestDirection.sent && i.id >= 300))
          .toList();
    }
  }

  @override
  Future<InterestItemModel> updateInterestStatus({
    required int interestId,
    required InterestStatus newStatus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _interests.indexWhere((i) => i.id == interestId);
    if (index != -1) {
      final updated = InterestItemModel.fromEntity(
        _interests[index].copyWith(status: newStatus),
      );
      _interests[index] = updated;
      return updated;
    }
    throw Exception('Interest item with id $interestId not found');
  }
}
