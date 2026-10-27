import 'package:equatable/equatable.dart';

class ExploreStartup extends Equatable {
  const ExploreStartup({
    required this.id,
    required this.name,
    required this.initials,
    required this.colorHex,
    required this.tagline,
    required this.about,
    required this.problem,
    required this.solution,
    required this.businessModel,
    required this.targetMarket,
    required this.industry,
    required this.location,
    required this.stage,
    required this.targetAmount,
    required this.raisedAmount,
    required this.valuation,
    required this.equityPct,
    required this.minInvestment,
    required this.deadline,
    required this.isVerified,
    required this.isFunded,
    required this.investorCount,
    required this.website,
    required this.mrr,
    required this.monthlyGrowth,
    required this.employees,
    required this.matchScore,
    required this.coverImageUrl,
    this.isSaved = false,
    this.isInterested = false,
  });

  final int id;
  final String name;
  final String initials;
  final int colorHex;
  final String tagline;
  final String about;
  final String problem;
  final String solution;
  final String businessModel;
  final String targetMarket;
  final String industry;
  final String location;
  final String stage;
  final double targetAmount;
  final double raisedAmount;
  final double valuation;
  final double equityPct;
  final double minInvestment;
  final String deadline;
  final bool isVerified;
  final bool isFunded;
  final int investorCount;
  final String website;
  final double mrr;
  final double monthlyGrowth;
  final int employees;
  final int matchScore;
  final String coverImageUrl;
  final bool isSaved;
  final bool isInterested;

  ExploreStartup copyWith({
    int? id,
    String? name,
    String? initials,
    int? colorHex,
    String? tagline,
    String? about,
    String? problem,
    String? solution,
    String? businessModel,
    String? targetMarket,
    String? industry,
    String? location,
    String? stage,
    double? targetAmount,
    double? raisedAmount,
    double? valuation,
    double? equityPct,
    double? minInvestment,
    String? deadline,
    bool? isVerified,
    bool? isFunded,
    int? investorCount,
    String? website,
    double? mrr,
    double? monthlyGrowth,
    int? employees,
    int? matchScore,
    String? coverImageUrl,
    bool? isSaved,
    bool? isInterested,
  }) {
    return ExploreStartup(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      colorHex: colorHex ?? this.colorHex,
      tagline: tagline ?? this.tagline,
      about: about ?? this.about,
      problem: problem ?? this.problem,
      solution: solution ?? this.solution,
      businessModel: businessModel ?? this.businessModel,
      targetMarket: targetMarket ?? this.targetMarket,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      stage: stage ?? this.stage,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      valuation: valuation ?? this.valuation,
      equityPct: equityPct ?? this.equityPct,
      minInvestment: minInvestment ?? this.minInvestment,
      deadline: deadline ?? this.deadline,
      isVerified: isVerified ?? this.isVerified,
      isFunded: isFunded ?? this.isFunded,
      investorCount: investorCount ?? this.investorCount,
      website: website ?? this.website,
      mrr: mrr ?? this.mrr,
      monthlyGrowth: monthlyGrowth ?? this.monthlyGrowth,
      employees: employees ?? this.employees,
      matchScore: matchScore ?? this.matchScore,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isSaved: isSaved ?? this.isSaved,
      isInterested: isInterested ?? this.isInterested,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        industry,
        location,
        stage,
        matchScore,
        isSaved,
        isInterested,
      ];
}
