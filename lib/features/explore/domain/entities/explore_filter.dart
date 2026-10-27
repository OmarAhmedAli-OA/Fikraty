import 'package:equatable/equatable.dart';

class ExploreFilter extends Equatable {
  const ExploreFilter({
    this.stages = const [],
    this.industries = const [],
    this.locations = const [],
    this.searchQuery = '',
  });

  final List<String> stages;
  final List<String> industries;
  final List<String> locations;
  final String searchQuery;

  static const List<String> availableStages = [
    'Pre-seed',
    'Seed',
    'Series A',
    'Series B',
    'Growth',
  ];

  static const List<String> availableIndustries = [
    'FinTech',
    'HealthTech',
    'AI / ML',
    'EdTech',
    'SaaS',
    'CleanTech',
    'E-commerce',
  ];

  static const List<String> availableLocations = [
    'Dubai, UAE',
    'Riyadh, KSA',
    'Cairo, Egypt',
    'Amman, Jordan',
    'Remote',
  ];

  int get activeCount => stages.length + industries.length + locations.length;
  bool get hasActiveFilters => activeCount > 0;

  ExploreFilter copyWith({
    List<String>? stages,
    List<String>? industries,
    List<String>? locations,
    String? searchQuery,
  }) {
    return ExploreFilter(
      stages: stages ?? this.stages,
      industries: industries ?? this.industries,
      locations: locations ?? this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  ExploreFilter clear() {
    return ExploreFilter(
      searchQuery: searchQuery,
      stages: const [],
      industries: const [],
      locations: const [],
    );
  }

  @override
  List<Object?> get props => [stages, industries, locations, searchQuery];
}
