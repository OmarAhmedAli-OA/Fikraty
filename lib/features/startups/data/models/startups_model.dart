import '../../domain/entities/startups.dart';

class StartupMemberModel extends StartupMemberEntity {
  const StartupMemberModel({
    required super.id,
    required super.fullName,
    required super.roleTitle,
    super.isCofounder,
    super.bio,
  });

  factory StartupMemberModel.fromJson(Map<String, dynamic> json) {
    return StartupMemberModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      roleTitle: json['role_title'] as String? ?? '',
      isCofounder: json['is_cofounder'] as bool? ?? false,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role_title': roleTitle,
      'is_cofounder': isCofounder,
      'bio': bio,
    };
  }

  factory StartupMemberModel.fromEntity(StartupMemberEntity entity) {
    return StartupMemberModel(
      id: entity.id,
      fullName: entity.fullName,
      roleTitle: entity.roleTitle,
      isCofounder: entity.isCofounder,
      bio: entity.bio,
    );
  }
}

class StartupModel extends StartupEntity {
  const StartupModel({
    required super.id,
    required super.ownerUserId,
    required super.name,
    required super.tagline,
    required super.description,
    required super.problem,
    required super.solution,
    required super.businessModel,
    required super.targetMarket,
    required super.industryName,
    required super.stageName,
    required super.cityName,
    super.websiteUrl,
    super.demoUrl,
    super.foundedYear,
    super.verificationStatus,
    super.isPublished,
    super.profileCompletion,
    super.followerCount,
    super.members,
    super.logoUrl,
    super.coverImageUrl,
    super.targetRaise = r'$250,000',
    super.fundingRound = 'Seed Round',
    super.minTicket = r'$5,000',
    super.valuationCap = r'$2,500,000',
    super.securityType = 'SAFE (Post-Money)',
    super.growthRate = '18% MoM',
    super.useOfFunds = '45% Product & Tech, 35% Marketing, 20% Operations',
    super.activeUsers = '15,000+',
    super.monthlyRevenue = r'$12,000/mo',
  });

  factory StartupModel.fromJson(Map<String, dynamic> json) {
    return StartupModel(
      id: json['id']?.toString() ?? '',
      ownerUserId: json['owner_user_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      problem: json['problem'] as String? ?? '',
      solution: json['solution'] as String? ?? '',
      businessModel: json['business_model'] as String? ?? '',
      targetMarket: json['target_market'] as String? ?? '',
      industryName: json['industry_name'] as String? ?? 'FinTech',
      stageName: json['stage_name'] as String? ?? 'MVP Ready',
      cityName: json['city_name'] as String? ?? 'Cairo',
      websiteUrl: json['website_url'] as String?,
      demoUrl: json['demo_url'] as String?,
      foundedYear: json['founded_year'] as int? ?? 2026,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      isPublished: json['is_published'] as bool? ?? true,
      profileCompletion: json['profile_completion'] as int? ?? 80,
      followerCount: json['follower_count'] as int? ?? 0,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      targetRaise: json['target_raise'] as String? ?? r'$250,000',
      fundingRound: json['funding_round'] as String? ?? 'Seed Round',
      minTicket: json['min_ticket'] as String? ?? r'$5,000',
      valuationCap: json['valuation_cap'] as String? ?? r'$2,500,000',
      securityType: json['security_type'] as String? ?? 'SAFE (Post-Money)',
      growthRate: json['growth_rate'] as String? ?? '18% MoM',
      useOfFunds: json['use_of_funds'] as String? ??
          '45% Product & Tech, 35% Marketing, 20% Operations',
      activeUsers: json['active_users'] as String? ?? '15,000+',
      monthlyRevenue: json['monthly_revenue'] as String? ?? r'$12,000/mo',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => StartupMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'tagline': tagline,
      'description': description,
      'problem': problem,
      'solution': solution,
      'business_model': businessModel,
      'target_market': targetMarket,
      'industry_name': industryName,
      'stage_name': stageName,
      'city_name': cityName,
      'website_url': websiteUrl,
      'demo_url': demoUrl,
      'founded_year': foundedYear,
      'verification_status': verificationStatus,
      'is_published': isPublished,
      'profile_completion': profileCompletion,
      'follower_count': followerCount,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'target_raise': targetRaise,
      'funding_round': fundingRound,
      'min_ticket': minTicket,
      'valuation_cap': valuationCap,
      'security_type': securityType,
      'growth_rate': growthRate,
      'use_of_funds': useOfFunds,
      'active_users': activeUsers,
      'monthly_revenue': monthlyRevenue,
      'members': members
          .map((m) => StartupMemberModel.fromEntity(m).toJson())
          .toList(),
    };
  }

  factory StartupModel.fromEntity(StartupEntity entity) {
    return StartupModel(
      id: entity.id,
      ownerUserId: entity.ownerUserId,
      name: entity.name,
      tagline: entity.tagline,
      description: entity.description,
      problem: entity.problem,
      solution: entity.solution,
      businessModel: entity.businessModel,
      targetMarket: entity.targetMarket,
      industryName: entity.industryName,
      stageName: entity.stageName,
      cityName: entity.cityName,
      websiteUrl: entity.websiteUrl,
      demoUrl: entity.demoUrl,
      foundedYear: entity.foundedYear,
      verificationStatus: entity.verificationStatus,
      isPublished: entity.isPublished,
      profileCompletion: entity.profileCompletion,
      followerCount: entity.followerCount,
      members: entity.members,
      logoUrl: entity.logoUrl,
      coverImageUrl: entity.coverImageUrl,
      targetRaise: entity.targetRaise,
      fundingRound: entity.fundingRound,
      minTicket: entity.minTicket,
      valuationCap: entity.valuationCap,
      securityType: entity.securityType,
      growthRate: entity.growthRate,
      useOfFunds: entity.useOfFunds,
      activeUsers: entity.activeUsers,
      monthlyRevenue: entity.monthlyRevenue,
    );
  }
}
