import 'package:equatable/equatable.dart';

class ExploreCampaign extends Equatable {
  const ExploreCampaign({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.initials,
    required this.colorHex,
    required this.coverImageUrl,
    required this.industry,
    required this.location,
    required this.matchScore,
    required this.investmentType,
    required this.stage,
    required this.deadline,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    required this.minTicket,
    this.isInterested = false,
    this.isSaved = false,
  });

  final int id;
  final int startupId;
  final String startupName;
  final String initials;
  final int colorHex;
  final String coverImageUrl;
  final String industry;
  final String location;
  final int matchScore;
  final String investmentType;
  final String stage;
  final String deadline;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final double minTicket;
  final bool isInterested;
  final bool isSaved;

  double get fundedPercentage =>
      targetAmount > 0 ? (raisedAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get remainingAmount =>
      (targetAmount - raisedAmount) > 0 ? (targetAmount - raisedAmount) : 0;

  ExploreCampaign copyWith({
    int? id,
    int? startupId,
    String? startupName,
    String? initials,
    int? colorHex,
    String? coverImageUrl,
    String? industry,
    String? location,
    int? matchScore,
    String? investmentType,
    String? stage,
    String? deadline,
    String? description,
    double? targetAmount,
    double? raisedAmount,
    double? minTicket,
    bool? isInterested,
    bool? isSaved,
  }) {
    return ExploreCampaign(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      startupName: startupName ?? this.startupName,
      initials: initials ?? this.initials,
      colorHex: colorHex ?? this.colorHex,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      matchScore: matchScore ?? this.matchScore,
      investmentType: investmentType ?? this.investmentType,
      stage: stage ?? this.stage,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      minTicket: minTicket ?? this.minTicket,
      isInterested: isInterested ?? this.isInterested,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startupId,
        startupName,
        stage,
        industry,
        isInterested,
        isSaved,
      ];
}
