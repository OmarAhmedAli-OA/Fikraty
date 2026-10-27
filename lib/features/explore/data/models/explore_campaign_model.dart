import '../../domain/entities/explore_campaign.dart';

class ExploreCampaignModel extends ExploreCampaign {
  const ExploreCampaignModel({
    required super.id,
    required super.startupId,
    required super.startupName,
    required super.initials,
    required super.colorHex,
    required super.coverImageUrl,
    required super.industry,
    required super.location,
    required super.matchScore,
    required super.investmentType,
    required super.stage,
    required super.deadline,
    required super.description,
    required super.targetAmount,
    required super.raisedAmount,
    required super.minTicket,
    super.isInterested,
    super.isSaved,
  });

  factory ExploreCampaignModel.fromJson(Map<String, dynamic> json) {
    return ExploreCampaignModel(
      id: json['id'] as int,
      startupId: json['startupId'] as int,
      startupName: json['startupName'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      colorHex: json['colorHex'] as int? ?? 0xFF5548E8,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      location: json['location'] as String? ?? '',
      matchScore: json['matchScore'] as int? ?? 0,
      investmentType: json['investmentType'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0.0,
      minTicket: (json['minTicket'] as num?)?.toDouble() ?? 0.0,
      isInterested: json['isInterested'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startupId': startupId,
      'startupName': startupName,
      'initials': initials,
      'colorHex': colorHex,
      'coverImageUrl': coverImageUrl,
      'industry': industry,
      'location': location,
      'matchScore': matchScore,
      'investmentType': investmentType,
      'stage': stage,
      'deadline': deadline,
      'description': description,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'minTicket': minTicket,
      'isInterested': isInterested,
      'isSaved': isSaved,
    };
  }
}
