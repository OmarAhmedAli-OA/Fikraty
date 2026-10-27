import 'package:equatable/equatable.dart';
import '../../domain/entities/compare_startup_item.dart';
import '../../domain/entities/explore_campaign.dart';
import '../../domain/entities/explore_content_item.dart';
import '../../domain/entities/explore_event.dart';
import '../../domain/entities/explore_founder.dart';
import '../../domain/entities/explore_investor.dart';
import '../../domain/entities/explore_startup.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitialState extends ExploreState {}

class ExploreLoadingState extends ExploreState {}

class ExploreErrorState extends ExploreState {
  const ExploreErrorState(this.errorMessage);
  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class ExploreLoadedState extends ExploreState {
  const ExploreLoadedState({
    required this.startups,
    required this.investors,
    required this.founders,
    required this.events,
    required this.campaigns,
    required this.compareStartups,
    required this.savedContentItems,
    this.selectedTabIndex = 0,
    this.userRole = 'entrepreneur',
    this.searchQuery = '',
    this.selectedStages = const [],
    this.selectedIndustries = const [],
    this.selectedLocations = const [],
    this.savedCategoryFilter = 'All',
    this.selectedCompareIds = const [1, 2],
    this.feedbackMessage,
  });

  final List<ExploreStartup> startups;
  final List<ExploreInvestor> investors;
  final List<ExploreFounder> founders;
  final List<ExploreEvent> events;
  final List<ExploreCampaign> campaigns;
  final List<CompareStartupItem> compareStartups;
  final List<ExploreContentItem> savedContentItems;
  final int selectedTabIndex;
  final String userRole; // 'entrepreneur' | 'investor'
  final String searchQuery;
  final List<String> selectedStages;
  final List<String> selectedIndustries;
  final List<String> selectedLocations;
  final String savedCategoryFilter;
  final List<int> selectedCompareIds;
  final String? feedbackMessage;

  static const List<String> defaultTabs = [
    'Startups',
    'Investors',
    'Founders',
    'Compare',
    'Saved',
  ];

  static const List<String> investorTabs = [
    'Investors',
    'Campaigns',
    'Founders',
    'Saved',
  ];

  static const List<String> savedCategories = [
    'All',
    'Startups',
    'Investors',
    'Founders',
    'Communities',
    'Knowledge',
    'Discussions',
    'Challenges',
  ];

  List<String> get currentTabs =>
      userRole == 'investor' ? investorTabs : defaultTabs;

  String get currentTabName {
    final tabs = currentTabs;
    final resolvedIndex = selectedTabIndex.clamp(0, tabs.length - 1);
    return tabs[resolvedIndex];
  }

  int get activeFiltersCount =>
      selectedStages.length +
      selectedIndustries.length +
      selectedLocations.length;

  List<ExploreStartup> get filteredStartups {
    final q = searchQuery.trim().toLowerCase();
    return startups.where((s) {
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.industry.toLowerCase().contains(q) ||
          s.tagline.toLowerCase().contains(q);

      final matchesIndustry = selectedIndustries.isEmpty ||
          selectedIndustries.any(
              (ind) => s.industry.toLowerCase().contains(ind.toLowerCase()));

      final matchesStage = selectedStages.isEmpty ||
          selectedStages.any(
              (st) => s.stage.toLowerCase().contains(st.toLowerCase()));

      final matchesLocation = selectedLocations.isEmpty ||
          selectedLocations.any(
              (loc) => s.location.toLowerCase().contains(loc.toLowerCase()));

      return matchesQuery &&
          matchesIndustry &&
          matchesStage &&
          matchesLocation;
    }).toList();
  }

  List<ExploreInvestor> get filteredInvestors {
    final q = searchQuery.trim().toLowerCase();
    return investors.where((inv) {
      final matchesQuery = q.isEmpty ||
          inv.name.toLowerCase().contains(q) ||
          inv.firm.toLowerCase().contains(q) ||
          inv.type.toLowerCase().contains(q);

      final matchesIndustry = selectedIndustries.isEmpty ||
          selectedIndustries.any((ind) => inv.industries
              .any((i) => i.toLowerCase().contains(ind.toLowerCase())));

      final matchesStage = selectedStages.isEmpty ||
          selectedStages.any((st) => inv.stages
              .any((s) => s.toLowerCase().contains(st.toLowerCase())));

      final matchesLocation = selectedLocations.isEmpty ||
          selectedLocations.any(
              (loc) => inv.location.toLowerCase().contains(loc.toLowerCase()));

      return matchesQuery &&
          matchesIndustry &&
          matchesStage &&
          matchesLocation;
    }).toList();
  }

  List<ExploreFounder> get filteredFounders {
    final q = searchQuery.trim().toLowerCase();
    return founders.where((f) {
      final matchesQuery = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.startupName.toLowerCase().contains(q) ||
          f.role.toLowerCase().contains(q);

      final matchesLocation = selectedLocations.isEmpty ||
          selectedLocations.any(
              (loc) => f.location.toLowerCase().contains(loc.toLowerCase()));

      return matchesQuery && matchesLocation;
    }).toList();
  }

  List<ExploreEvent> get filteredEvents {
    final q = searchQuery.trim().toLowerCase();
    return events.where((e) {
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.type.toLowerCase().contains(q) ||
          e.organizer.toLowerCase().contains(q);

      final matchesLocation = selectedLocations.isEmpty ||
          (e.isOnline && selectedLocations.contains('Remote')) ||
          selectedLocations.any(
              (loc) => e.location.toLowerCase().contains(loc.toLowerCase()));

      return matchesQuery && matchesLocation;
    }).toList();
  }

  List<ExploreCampaign> get filteredCampaigns {
    final q = searchQuery.trim().toLowerCase();
    return campaigns.where((c) {
      final matchesQuery = q.isEmpty ||
          c.startupName.toLowerCase().contains(q) ||
          c.industry.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);

      final matchesIndustry = selectedIndustries.isEmpty ||
          selectedIndustries.any(
              (ind) => c.industry.toLowerCase().contains(ind.toLowerCase()));

      final matchesStage = selectedStages.isEmpty ||
          selectedStages.any(
              (st) => c.stage.toLowerCase().contains(st.toLowerCase()));

      final matchesLocation = selectedLocations.isEmpty ||
          selectedLocations.any(
              (loc) => c.location.toLowerCase().contains(loc.toLowerCase()));

      return matchesQuery &&
          matchesIndustry &&
          matchesStage &&
          matchesLocation;
    }).toList();
  }

  List<dynamic> get savedItemsList {
    final List<dynamic> list = [];
    if (savedCategoryFilter == 'All' || savedCategoryFilter == 'Startups') {
      list.addAll(startups.where((s) => s.isSaved));
    }
    if (savedCategoryFilter == 'All' || savedCategoryFilter == 'Investors') {
      list.addAll(investors.where((i) => i.isSaved));
    }
    if (savedCategoryFilter == 'All' || savedCategoryFilter == 'Founders') {
      list.addAll(founders.where((f) => f.isSaved));
    }

    for (final item in savedContentItems) {
      if (!item.isSaved) continue;
      if (savedCategoryFilter == 'All') {
        list.add(item);
      } else if (savedCategoryFilter == 'Communities' &&
          item.type == ExploreContentType.community) {
        list.add(item);
      } else if (savedCategoryFilter == 'Knowledge' &&
          item.type == ExploreContentType.knowledge) {
        list.add(item);
      } else if (savedCategoryFilter == 'Discussions' &&
          item.type == ExploreContentType.discussion) {
        list.add(item);
      } else if (savedCategoryFilter == 'Challenges' &&
          item.type == ExploreContentType.challenge) {
        list.add(item);
      }
    }
    return list;
  }

  int get totalSavedCount {
    int count = 0;
    count += startups.where((s) => s.isSaved).length;
    count += investors.where((i) => i.isSaved).length;
    count += founders.where((f) => f.isSaved).length;

    count += savedContentItems.where((c) => c.isSaved).length;
    return count;
  }

  ExploreLoadedState copyWith({
    List<ExploreStartup>? startups,
    List<ExploreInvestor>? investors,
    List<ExploreFounder>? founders,
    List<ExploreEvent>? events,
    List<ExploreCampaign>? campaigns,
    List<CompareStartupItem>? compareStartups,
    List<ExploreContentItem>? savedContentItems,
    int? selectedTabIndex,
    String? userRole,
    String? searchQuery,
    List<String>? selectedStages,
    List<String>? selectedIndustries,
    List<String>? selectedLocations,
    String? savedCategoryFilter,
    List<int>? selectedCompareIds,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ExploreLoadedState(
      startups: startups ?? this.startups,
      investors: investors ?? this.investors,
      founders: founders ?? this.founders,
      events: events ?? this.events,
      campaigns: campaigns ?? this.campaigns,
      compareStartups: compareStartups ?? this.compareStartups,
      savedContentItems: savedContentItems ?? this.savedContentItems,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      userRole: userRole ?? this.userRole,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStages: selectedStages ?? this.selectedStages,
      selectedIndustries: selectedIndustries ?? this.selectedIndustries,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      savedCategoryFilter: savedCategoryFilter ?? this.savedCategoryFilter,
      selectedCompareIds: selectedCompareIds ?? this.selectedCompareIds,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props => [
        startups,
        investors,
        founders,
        events,
        campaigns,
        compareStartups,
        savedContentItems,
        selectedTabIndex,
        userRole,
        searchQuery,
        selectedStages,
        selectedIndustries,
        selectedLocations,
        savedCategoryFilter,
        selectedCompareIds,
        feedbackMessage,
      ];
}
