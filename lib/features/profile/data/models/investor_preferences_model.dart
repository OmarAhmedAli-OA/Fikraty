import '../../domain/entities/investor_preferences.dart';

class InvestorPreferencesModel extends InvestorPreferences {
  const InvestorPreferencesModel({
    super.sectors = const ['HealthTech', 'FinTech', 'AI / ML'],
    super.stages = const ['Seed', 'Series A'],
    super.countries = const ['UAE', 'Saudi Arabia', 'Egypt'],
    super.ticketMin = '\$50K',
    super.ticketMax = '\$500K',
    super.dealTypes = const ['Equity'],
    super.investmentThesis =
        'I back founders who deeply understand their market and build with capital efficiency.',
    super.openToCoInvesting = true,
    super.advisoryRoles = true,
    super.boardSeats = false,
    super.notifyMatches = true,
    super.notifyMessages = true,
    super.isCompleted = true,
  });

  factory InvestorPreferencesModel.fromEntity(InvestorPreferences entity) {
    return InvestorPreferencesModel(
      sectors: entity.sectors,
      stages: entity.stages,
      countries: entity.countries,
      ticketMin: entity.ticketMin,
      ticketMax: entity.ticketMax,
      dealTypes: entity.dealTypes,
      investmentThesis: entity.investmentThesis,
      openToCoInvesting: entity.openToCoInvesting,
      advisoryRoles: entity.advisoryRoles,
      boardSeats: entity.boardSeats,
      notifyMatches: entity.notifyMatches,
      notifyMessages: entity.notifyMessages,
      isCompleted: entity.isCompleted,
    );
  }

  factory InvestorPreferencesModel.fromMap(Map<String, dynamic> map) {
    return InvestorPreferencesModel(
      sectors: (map['sectors'] as List<dynamic>?)?.cast<String>() ??
          ['HealthTech', 'FinTech', 'AI / ML'],
      stages: (map['stages'] as List<dynamic>?)?.cast<String>() ??
          ['Seed', 'Series A'],
      countries: (map['countries'] as List<dynamic>?)?.cast<String>() ??
          ['UAE', 'Saudi Arabia', 'Egypt'],
      ticketMin: map['ticketMin'] as String? ?? '\$50K',
      ticketMax: map['ticketMax'] as String? ?? '\$500K',
      dealTypes: (map['dealTypes'] as List<dynamic>?)?.cast<String>() ??
          ['Equity'],
      investmentThesis: map['investmentThesis'] as String? ?? '',
      openToCoInvesting: map['openToCoInvesting'] as bool? ?? true,
      advisoryRoles: map['advisoryRoles'] as bool? ?? true,
      boardSeats: map['boardSeats'] as bool? ?? false,
      notifyMatches: map['notifyMatches'] as bool? ?? true,
      notifyMessages: map['notifyMessages'] as bool? ?? true,
      isCompleted: map['isCompleted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectors': sectors,
      'stages': stages,
      'countries': countries,
      'ticketMin': ticketMin,
      'ticketMax': ticketMax,
      'dealTypes': dealTypes,
      'investmentThesis': investmentThesis,
      'openToCoInvesting': openToCoInvesting,
      'advisoryRoles': advisoryRoles,
      'boardSeats': boardSeats,
      'notifyMatches': notifyMatches,
      'notifyMessages': notifyMessages,
      'isCompleted': isCompleted,
    };
  }
}
