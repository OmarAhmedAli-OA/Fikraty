import '../../domain/entities/explore_investor.dart';

class ExploreInvestorModel extends ExploreInvestor {
  const ExploreInvestorModel({
    required super.id,
    required super.name,
    required super.type,
    required super.firm,
    required super.avatarUrl,
    required super.bio,
    required super.thesis,
    required super.industries,
    required super.stages,
    required super.ticket,
    required super.minTicket,
    required super.maxTicket,
    required super.location,
    required super.matchScore,
    required super.isVerified,
    required super.portfolio,
    required super.totalInvested,
    required super.activeDeals,
    required super.followers,
    required super.matchReasons,
    super.isSaved = false,
    super.isInterestSent = false,
    super.isFollowing = false,
  });

  factory ExploreInvestorModel.fromJson(Map<String, dynamic> json) {
    return ExploreInvestorModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      firm: json['firm'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      thesis: json['thesis'] as String? ?? '',
      industries: (json['industries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ticket: json['ticket'] as String? ?? '',
      minTicket: (json['minTicket'] as num?)?.toDouble() ?? 0.0,
      maxTicket: (json['maxTicket'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      matchScore: json['matchScore'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      portfolio: (json['portfolio'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalInvested: json['totalInvested'] as String? ?? '',
      activeDeals: json['activeDeals'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      matchReasons: (json['matchReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSaved: json['isSaved'] as bool? ?? false,
      isInterestSent: json['isInterestSent'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'firm': firm,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'thesis': thesis,
      'industries': industries,
      'stages': stages,
      'ticket': ticket,
      'minTicket': minTicket,
      'maxTicket': maxTicket,
      'location': location,
      'matchScore': matchScore,
      'isVerified': isVerified,
      'portfolio': portfolio,
      'totalInvested': totalInvested,
      'activeDeals': activeDeals,
      'followers': followers,
      'matchReasons': matchReasons,
      'isSaved': isSaved,
      'isInterestSent': isInterestSent,
      'isFollowing': isFollowing,
    };
  }
}
