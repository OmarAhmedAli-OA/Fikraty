import 'package:equatable/equatable.dart';

class ExploreInvestor extends Equatable {
  const ExploreInvestor({
    required this.id,
    required this.name,
    required this.type,
    required this.firm,
    required this.avatarUrl,
    required this.bio,
    required this.thesis,
    required this.industries,
    required this.stages,
    required this.ticket,
    required this.minTicket,
    required this.maxTicket,
    required this.location,
    required this.matchScore,
    required this.isVerified,
    required this.portfolio,
    required this.totalInvested,
    required this.activeDeals,
    required this.followers,
    required this.matchReasons,
    this.isSaved = false,
    this.isInterestSent = false,
    this.isFollowing = false,
  });

  final int id;
  final String name;
  final String type;
  final String firm;
  final String avatarUrl;
  final String bio;
  final String thesis;
  final List<String> industries;
  final List<String> stages;
  final String ticket;
  final double minTicket;
  final double maxTicket;
  final String location;
  final int matchScore;
  final bool isVerified;
  final List<String> portfolio;
  final String totalInvested;
  final int activeDeals;
  final int followers;
  final List<String> matchReasons;
  final bool isSaved;
  final bool isInterestSent;
  final bool isFollowing;

  ExploreInvestor copyWith({
    int? id,
    String? name,
    String? type,
    String? firm,
    String? avatarUrl,
    String? bio,
    String? thesis,
    List<String>? industries,
    List<String>? stages,
    String? ticket,
    double? minTicket,
    double? maxTicket,
    String? location,
    int? matchScore,
    bool? isVerified,
    List<String>? portfolio,
    String? totalInvested,
    int? activeDeals,
    int? followers,
    List<String>? matchReasons,
    bool? isSaved,
    bool? isInterestSent,
    bool? isFollowing,
  }) {
    return ExploreInvestor(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      firm: firm ?? this.firm,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      thesis: thesis ?? this.thesis,
      industries: industries ?? this.industries,
      stages: stages ?? this.stages,
      ticket: ticket ?? this.ticket,
      minTicket: minTicket ?? this.minTicket,
      maxTicket: maxTicket ?? this.maxTicket,
      location: location ?? this.location,
      matchScore: matchScore ?? this.matchScore,
      isVerified: isVerified ?? this.isVerified,
      portfolio: portfolio ?? this.portfolio,
      totalInvested: totalInvested ?? this.totalInvested,
      activeDeals: activeDeals ?? this.activeDeals,
      followers: followers ?? this.followers,
      matchReasons: matchReasons ?? this.matchReasons,
      isSaved: isSaved ?? this.isSaved,
      isInterestSent: isInterestSent ?? this.isInterestSent,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        firm,
        location,
        matchScore,
        isSaved,
        isInterestSent,
        isFollowing,
      ];
}
