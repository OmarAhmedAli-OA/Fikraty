import 'package:equatable/equatable.dart';

class StartupMemberEntity extends Equatable {
  const StartupMemberEntity({
    required this.id,
    required this.fullName,
    required this.roleTitle,
    this.isCofounder = false,
    this.bio,
  });

  final String id;
  final String fullName;
  final String roleTitle;
  final bool isCofounder;
  final String? bio;

  StartupMemberEntity copyWith({
    String? id,
    String? fullName,
    String? roleTitle,
    bool? isCofounder,
    String? bio,
  }) {
    return StartupMemberEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      roleTitle: roleTitle ?? this.roleTitle,
      isCofounder: isCofounder ?? this.isCofounder,
      bio: bio ?? this.bio,
    );
  }

  @override
  List<Object?> get props => [id, fullName, roleTitle, isCofounder, bio];
}

class StartupEntity extends Equatable {
  const StartupEntity({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.problem,
    required this.solution,
    required this.businessModel,
    required this.targetMarket,
    required this.industryName,
    required this.stageName,
    required this.cityName,
    this.websiteUrl,
    this.demoUrl,
    this.foundedYear = 2026,
    this.verificationStatus = 'unverified',
    this.isPublished = true,
    this.profileCompletion = 85,
    this.followerCount = 0,
    this.members = const [],
    this.logoUrl,
    this.coverImageUrl,
    this.targetRaise = r'$250,000',
    this.fundingRound = 'Seed Round',
    this.minTicket = r'$5,000',
    this.valuationCap = r'$2,500,000',
    this.securityType = 'SAFE (Post-Money)',
    this.growthRate = '18% MoM',
    this.useOfFunds = '45% Product & Tech, 35% Marketing, 20% Operations',
    this.activeUsers = '15,000+',
    this.monthlyRevenue = r'$12,000/mo',
  });

  final String id;
  final String ownerUserId;
  final String name;
  final String tagline;
  final String description;
  final String problem;
  final String solution;
  final String businessModel;
  final String targetMarket;
  final String industryName;
  final String stageName;
  final String cityName;
  final String? websiteUrl;
  final String? demoUrl;
  final int foundedYear;
  final String
  verificationStatus; // unverified, pending, under_review, approved, rejected
  final bool isPublished;
  final int profileCompletion;
  final int followerCount;
  final List<StartupMemberEntity> members;
  final String? logoUrl;
  final String? coverImageUrl;
  final String targetRaise;
  final String fundingRound;
  final String minTicket;
  final String valuationCap;
  final String securityType;
  final String growthRate;
  final String useOfFunds;
  final String activeUsers;
  final String monthlyRevenue;

  StartupEntity copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? tagline,
    String? description,
    String? problem,
    String? solution,
    String? businessModel,
    String? targetMarket,
    String? industryName,
    String? stageName,
    String? cityName,
    String? websiteUrl,
    String? demoUrl,
    int? foundedYear,
    String? verificationStatus,
    bool? isPublished,
    int? profileCompletion,
    int? followerCount,
    List<StartupMemberEntity>? members,
    String? logoUrl,
    String? coverImageUrl,
    String? targetRaise,
    String? fundingRound,
    String? minTicket,
    String? valuationCap,
    String? securityType,
    String? growthRate,
    String? useOfFunds,
    String? activeUsers,
    String? monthlyRevenue,
  }) {
    return StartupEntity(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      problem: problem ?? this.problem,
      solution: solution ?? this.solution,
      businessModel: businessModel ?? this.businessModel,
      targetMarket: targetMarket ?? this.targetMarket,
      industryName: industryName ?? this.industryName,
      stageName: stageName ?? this.stageName,
      cityName: cityName ?? this.cityName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      demoUrl: demoUrl ?? this.demoUrl,
      foundedYear: foundedYear ?? this.foundedYear,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isPublished: isPublished ?? this.isPublished,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      followerCount: followerCount ?? this.followerCount,
      members: members ?? this.members,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      targetRaise: targetRaise ?? this.targetRaise,
      fundingRound: fundingRound ?? this.fundingRound,
      minTicket: minTicket ?? this.minTicket,
      valuationCap: valuationCap ?? this.valuationCap,
      securityType: securityType ?? this.securityType,
      growthRate: growthRate ?? this.growthRate,
      useOfFunds: useOfFunds ?? this.useOfFunds,
      activeUsers: activeUsers ?? this.activeUsers,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerUserId,
    name,
    tagline,
    description,
    problem,
    solution,
    businessModel,
    targetMarket,
    industryName,
    stageName,
    cityName,
    websiteUrl,
    demoUrl,
    foundedYear,
    verificationStatus,
    isPublished,
    profileCompletion,
    followerCount,
    members,
    logoUrl,
    coverImageUrl,
    targetRaise,
    fundingRound,
    minTicket,
    valuationCap,
    securityType,
    growthRate,
    useOfFunds,
    activeUsers,
    monthlyRevenue,
  ];
}
