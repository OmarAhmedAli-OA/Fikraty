import 'package:equatable/equatable.dart';

class CompareStartupItem extends Equatable {
  const CompareStartupItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.colorHex,
    required this.score,
    required this.industry,
    required this.stage,
    required this.raised,
    required this.mrr,
    required this.monthlyGrowth,
    required this.runway,
  });

  final int id;
  final String name;
  final String initials;
  final int colorHex;
  final int score;
  final String industry;
  final String stage;
  final String raised;
  final String mrr;
  final String monthlyGrowth;
  final String runway;

  List<String> get metricValues => [
        industry,
        stage,
        raised,
        mrr,
        monthlyGrowth,
        runway,
      ];

  static const List<String> metricLabels = [
    'Industry',
    'Stage',
    'Raised',
    'MRR',
    'Monthly growth',
    'Runway',
  ];

  @override
  List<Object?> get props => [id, name, score, industry, stage];
}
