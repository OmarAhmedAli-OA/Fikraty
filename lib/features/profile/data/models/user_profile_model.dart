import '../../../../core/constants/countries.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.role,
    required super.fullName,
    required super.title,
    required super.bio,
    super.background = '',
    required super.location,
    required super.country,
    required super.photoUrl,
    super.coverUrl = '',
    super.website = '',
    super.linkedIn = '',
    super.twitter = '',
    super.angelList = '',
    super.expertise = const [],
    super.companyName = '',
    super.industry = '',
    super.companyStage = '',
    super.firmName = '',
    super.fundSize = '',
    super.yearsInvesting = '',
    super.isVerified = true,
    super.verificationBadge = '',
    super.followersCount = 0,
    super.followingCount = 0,
    super.investorInterestCount = 0,
    super.portfolioCount = 0,
    super.totalDeployed = '',
    super.thesisQuote = '',
    super.profileViews = 2840,
    super.email = 'sarah@novamed.ai',
    super.phone = '+971 50 123 4567',
    super.profileVisibility = 'Public',
    super.messagingFrom = 'Everyone',
    super.posts = const [],
    super.portfolioStartups = const [],
    super.documents = const [],
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      role: entity.role,
      fullName: entity.fullName,
      title: entity.title,
      bio: entity.bio,
      background: entity.background,
      location: entity.location,
      country: entity.country,
      photoUrl: entity.photoUrl,
      coverUrl: entity.coverUrl,
      website: entity.website,
      linkedIn: entity.linkedIn,
      twitter: entity.twitter,
      angelList: entity.angelList,
      expertise: entity.expertise,
      companyName: entity.companyName,
      industry: entity.industry,
      companyStage: entity.companyStage,
      firmName: entity.firmName,
      fundSize: entity.fundSize,
      yearsInvesting: entity.yearsInvesting,
      isVerified: entity.isVerified,
      verificationBadge: entity.verificationBadge,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      investorInterestCount: entity.investorInterestCount,
      portfolioCount: entity.portfolioCount,
      totalDeployed: entity.totalDeployed,
      thesisQuote: entity.thesisQuote,
      profileViews: entity.profileViews,
      email: entity.email,
      phone: entity.phone,
      profileVisibility: entity.profileVisibility,
      messagingFrom: entity.messagingFrom,
      posts: entity.posts,
      portfolioStartups: entity.portfolioStartups,
      documents: entity.documents,
    );
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    final roleStr = map['role'] as String? ?? 'entrepreneur';
    final role =
        roleStr == 'investor' ? UserRole.investor : UserRole.entrepreneur;
    final countryMap = map['country'] as Map<String, dynamic>?;
    final country = countryMap != null
        ? Country.fromMap(countryMap)
        : AppCountries.findByCode(map['countryCode'] as String? ?? 'EG');

    final rawPosts = map['posts'] as List<dynamic>? ?? [];
    final posts = rawPosts.map((p) {
      final pm = p as Map<String, dynamic>;
      return UserPost(
        id: pm['id'] as int? ?? 0,
        text: pm['text'] as String? ?? '',
        likes: pm['likes'] as int? ?? 0,
        time: pm['time'] as String? ?? '',
        isLikedByMe: pm['isLikedByMe'] as bool? ?? false,
      );
    }).toList();

    final rawStartups = map['portfolioStartups'] as List<dynamic>? ?? [];
    final portfolioStartups = rawStartups.map((s) {
      final sm = s as Map<String, dynamic>;
      return PortfolioStartup(
        id: sm['id'] as int? ?? 0,
        name: sm['name'] as String? ?? '',
        sector: sm['sector'] as String? ?? '',
        status: sm['status'] as String? ?? 'Active',
        initials: sm['initials'] as String? ?? '',
        colorValue: sm['colorValue'] as int? ?? 0xFF5548E8,
      );
    }).toList();

    final rawDocs = map['documents'] as List<dynamic>? ?? [];
    final documents = rawDocs
        .map((d) => ProfileDocument.fromMap(d as Map<String, dynamic>))
        .toList();

    return UserProfileModel(
      id: map['id']?.toString() ?? '1',
      role: role,
      fullName: map['fullName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      background: map['background'] as String? ?? '',
      location: map['location'] as String? ?? '',
      country: country,
      photoUrl: map['photoUrl'] as String? ?? '',
      coverUrl: map['coverUrl'] as String? ?? '',
      website: map['website'] as String? ?? '',
      linkedIn: map['linkedIn'] as String? ?? '',
      twitter: map['twitter'] as String? ?? '',
      angelList: map['angelList'] as String? ?? '',
      expertise: (map['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
      companyName: map['companyName'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      companyStage: map['companyStage'] as String? ?? '',
      firmName: map['firmName'] as String? ?? '',
      fundSize: map['fundSize'] as String? ?? '',
      yearsInvesting: map['yearsInvesting'] as String? ?? '',
      isVerified: map['isVerified'] as bool? ?? true,
      verificationBadge: map['verificationBadge'] as String? ?? '',
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
      investorInterestCount: map['investorInterestCount'] as int? ?? 0,
      portfolioCount: map['portfolioCount'] as int? ?? 0,
      totalDeployed: map['totalDeployed'] as String? ?? '',
      thesisQuote: map['thesisQuote'] as String? ?? '',
      profileViews: map['profileViews'] as int? ?? 2840,
      email: map['email'] as String? ?? 'sarah@novamed.ai',
      phone: map['phone'] as String? ?? '+971 50 123 4567',
      profileVisibility: map['profileVisibility'] as String? ?? 'Public',
      messagingFrom: map['messagingFrom'] as String? ?? 'Everyone',
      posts: posts,
      portfolioStartups: portfolioStartups,
      documents: documents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.name,
      'fullName': fullName,
      'title': title,
      'bio': bio,
      'background': background,
      'location': location,
      'country': country.toMap(),
      'photoUrl': photoUrl,
      'coverUrl': coverUrl,
      'website': website,
      'linkedIn': linkedIn,
      'twitter': twitter,
      'angelList': angelList,
      'expertise': expertise,
      'companyName': companyName,
      'industry': industry,
      'companyStage': companyStage,
      'firmName': firmName,
      'fundSize': fundSize,
      'yearsInvesting': yearsInvesting,
      'isVerified': isVerified,
      'verificationBadge': verificationBadge,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'investorInterestCount': investorInterestCount,
      'portfolioCount': portfolioCount,
      'totalDeployed': totalDeployed,
      'thesisQuote': thesisQuote,
      'profileViews': profileViews,
      'email': email,
      'phone': phone,
      'profileVisibility': profileVisibility,
      'messagingFrom': messagingFrom,
      'posts': posts
          .map((p) => {
                'id': p.id,
                'text': p.text,
                'likes': p.likes,
                'time': p.time,
                'isLikedByMe': p.isLikedByMe,
              })
          .toList(),
      'portfolioStartups': portfolioStartups
          .map((s) => {
                'id': s.id,
                'name': s.name,
                'sector': s.sector,
                'status': s.status,
                'initials': s.initials,
                'colorValue': s.colorValue,
              })
          .toList(),
      'documents': documents.map((d) => d.toMap()).toList(),
    };
  }
}
