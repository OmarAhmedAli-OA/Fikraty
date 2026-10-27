import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExploreDataEvent extends ExploreEvent {
  const LoadExploreDataEvent({this.isRefresh = false});
  final bool isRefresh;

  @override
  List<Object?> get props => [isRefresh];
}

class ChangeExploreTabEvent extends ExploreEvent {
  const ChangeExploreTabEvent(this.tabIndex);
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class SearchExploreQueryEvent extends ExploreEvent {
  const SearchExploreQueryEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class ToggleFilterStageEvent extends ExploreEvent {
  const ToggleFilterStageEvent(this.stage);
  final String stage;

  @override
  List<Object?> get props => [stage];
}

class ToggleFilterIndustryEvent extends ExploreEvent {
  const ToggleFilterIndustryEvent(this.industry);
  final String industry;

  @override
  List<Object?> get props => [industry];
}

class ToggleFilterLocationEvent extends ExploreEvent {
  const ToggleFilterLocationEvent(this.location);
  final String location;

  @override
  List<Object?> get props => [location];
}

class ClearAllFiltersEvent extends ExploreEvent {
  const ClearAllFiltersEvent();
}

class ToggleBookmarkEvent extends ExploreEvent {
  const ToggleBookmarkEvent({required this.type, required this.id});
  final String type;
  final int id;

  @override
  List<Object?> get props => [type, id];
}

class ExpressInterestEvent extends ExploreEvent {
  const ExpressInterestEvent({required this.type, required this.id});
  final String type;
  final int id;

  @override
  List<Object?> get props => [type, id];
}

class ToggleEventRegistrationEvent extends ExploreEvent {
  const ToggleEventRegistrationEvent(this.eventId);
  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class FilterSavedCategoryEvent extends ExploreEvent {
  const FilterSavedCategoryEvent(this.category);
  final String category;

  @override
  List<Object?> get props => [category];
}

class ToggleCompareStartupEvent extends ExploreEvent {
  const ToggleCompareStartupEvent(this.startupId);
  final int startupId;

  @override
  List<Object?> get props => [startupId];
}

class SwitchRoleEvent extends ExploreEvent {
  const SwitchRoleEvent(this.role);
  final String role; // 'entrepreneur' or 'investor'

  @override
  List<Object?> get props => [role];
}

class ToggleFollowEvent extends ExploreEvent {
  const ToggleFollowEvent({required this.type, required this.id});
  final String type;
  final int id;

  @override
  List<Object?> get props => [type, id];
}
