import 'package:equatable/equatable.dart';

class InvestorPreferences extends Equatable {
  final List<String> sectors;
  final List<String> stages;
  final List<String> countries;
  final String ticketMin;
  final String ticketMax;
  final List<String> dealTypes;
  final String investmentThesis;
  final bool openToCoInvesting;
  final bool advisoryRoles;
  final bool boardSeats;
  final bool notifyMatches;
  final bool notifyMessages;
  final bool isCompleted;

  const InvestorPreferences({
    this.sectors = const ['HealthTech', 'FinTech', 'AI / ML'],
    this.stages = const ['Seed', 'Series A'],
    this.countries = const ['UAE', 'Saudi Arabia', 'Egypt'],
    this.ticketMin = '\$50K',
    this.ticketMax = '\$500K',
    this.dealTypes = const ['Equity'],
    this.investmentThesis =
        'I back founders who deeply understand their market and build with capital efficiency.',
    this.openToCoInvesting = true,
    this.advisoryRoles = true,
    this.boardSeats = false,
    this.notifyMatches = true,
    this.notifyMessages = true,
    this.isCompleted = true,
  });

  String get ticketSizeFormatted {
    if (ticketMin.isNotEmpty && ticketMax.isNotEmpty) {
      return '$ticketMin – $ticketMax';
    } else if (ticketMin.isNotEmpty) {
      return 'Min $ticketMin';
    } else if (ticketMax.isNotEmpty) {
      return 'Max $ticketMax';
    }
    return '\$50K – \$500K';
  }

  InvestorPreferences copyWith({
    List<String>? sectors,
    List<String>? stages,
    List<String>? countries,
    String? ticketMin,
    String? ticketMax,
    List<String>? dealTypes,
    String? investmentThesis,
    bool? openToCoInvesting,
    bool? advisoryRoles,
    bool? boardSeats,
    bool? notifyMatches,
    bool? notifyMessages,
    bool? isCompleted,
  }) {
    return InvestorPreferences(
      sectors: sectors ?? this.sectors,
      stages: stages ?? this.stages,
      countries: countries ?? this.countries,
      ticketMin: ticketMin ?? this.ticketMin,
      ticketMax: ticketMax ?? this.ticketMax,
      dealTypes: dealTypes ?? this.dealTypes,
      investmentThesis: investmentThesis ?? this.investmentThesis,
      openToCoInvesting: openToCoInvesting ?? this.openToCoInvesting,
      advisoryRoles: advisoryRoles ?? this.advisoryRoles,
      boardSeats: boardSeats ?? this.boardSeats,
      notifyMatches: notifyMatches ?? this.notifyMatches,
      notifyMessages: notifyMessages ?? this.notifyMessages,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        sectors,
        stages,
        countries,
        ticketMin,
        ticketMax,
        dealTypes,
        investmentThesis,
        openToCoInvesting,
        advisoryRoles,
        boardSeats,
        notifyMatches,
        notifyMessages,
        isCompleted,
      ];
}
