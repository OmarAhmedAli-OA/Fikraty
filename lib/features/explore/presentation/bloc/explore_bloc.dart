import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/express_interest_usecase.dart';
import '../../domain/usecases/get_explore_data_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import '../../domain/usecases/toggle_event_registration_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc({
    required this.getExploreDataUseCase,
    required this.toggleBookmarkUseCase,
    required this.expressInterestUseCase,
    required this.toggleEventRegistrationUseCase,
    required this.toggleFollowUseCase,
  }) : super(ExploreInitialState()) {
    on<LoadExploreDataEvent>(_onLoadExploreData);
    on<ChangeExploreTabEvent>(_onChangeExploreTab);
    on<SearchExploreQueryEvent>(_onSearchQuery);
    on<ToggleFilterStageEvent>(_onToggleFilterStage);
    on<ToggleFilterIndustryEvent>(_onToggleFilterIndustry);
    on<ToggleFilterLocationEvent>(_onToggleFilterLocation);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<ExpressInterestEvent>(_onExpressInterest);
    on<ToggleEventRegistrationEvent>(_onToggleEventRegistration);
    on<FilterSavedCategoryEvent>(_onFilterSavedCategory);
    on<ToggleCompareStartupEvent>(_onToggleCompareStartup);
    on<SwitchRoleEvent>(_onSwitchRole);
    on<ToggleFollowEvent>(_onToggleFollow);
  }

  final GetExploreDataUseCase getExploreDataUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final ExpressInterestUseCase expressInterestUseCase;
  final ToggleEventRegistrationUseCase toggleEventRegistrationUseCase;
  final ToggleFollowUseCase toggleFollowUseCase;

  Future<void> _onLoadExploreData(
    LoadExploreDataEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(ExploreLoadingState());
    }

    final result = await getExploreDataUseCase();
    final bundle = result.rightOrNull;
    if (bundle != null) {
      final currentRole = state is ExploreLoadedState
          ? (state as ExploreLoadedState).userRole
          : 'entrepreneur';
      emit(
        ExploreLoadedState(
          startups: bundle.startups,
          investors: bundle.investors,
          founders: bundle.founders,
          events: bundle.events,
          campaigns: bundle.campaigns,
          compareStartups: bundle.compareStartups,
          savedContentItems: bundle.savedItems,
          userRole: currentRole,
        ),
      );
    } else {
      final errorMsg =
          result.leftOrNull?.message ?? 'Failed to load explore data.';
      emit(ExploreErrorState(errorMsg));
    }
  }

  void _onChangeExploreTab(
    ChangeExploreTabEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      emit(loaded.copyWith(
        selectedTabIndex: event.tabIndex,
        clearFeedback: true,
      ));
    }
  }

  void _onSearchQuery(
    SearchExploreQueryEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      emit(loaded.copyWith(
        searchQuery: event.query,
        clearFeedback: true,
      ));
    }
  }

  void _onToggleFilterStage(
    ToggleFilterStageEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      final stages = List<String>.from(loaded.selectedStages);
      if (stages.contains(event.stage)) {
        stages.remove(event.stage);
      } else {
        stages.add(event.stage);
      }
      emit(loaded.copyWith(selectedStages: stages, clearFeedback: true));
    }
  }

  void _onToggleFilterIndustry(
    ToggleFilterIndustryEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      final industries = List<String>.from(loaded.selectedIndustries);
      if (industries.contains(event.industry)) {
        industries.remove(event.industry);
      } else {
        industries.add(event.industry);
      }
      emit(loaded.copyWith(selectedIndustries: industries, clearFeedback: true));
    }
  }

  void _onToggleFilterLocation(
    ToggleFilterLocationEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      final locations = List<String>.from(loaded.selectedLocations);
      if (locations.contains(event.location)) {
        locations.remove(event.location);
      } else {
        locations.add(event.location);
      }
      emit(loaded.copyWith(selectedLocations: locations, clearFeedback: true));
    }
  }

  void _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      emit(loaded.copyWith(
        selectedStages: const [],
        selectedIndustries: const [],
        selectedLocations: const [],
        clearFeedback: true,
      ));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoadedState) return;
    final loaded = state as ExploreLoadedState;

    final result = await toggleBookmarkUseCase(type: event.type, id: event.id);
    final isSaved = result.rightOrNull;
    if (isSaved == null) return;

    if (event.type == 'startup') {
      final updated = loaded.startups.map((s) {
        return s.id == event.id ? s.copyWith(isSaved: isSaved) : s;
      }).toList();
      emit(loaded.copyWith(
        startups: updated,
        feedbackMessage: isSaved
            ? 'Startup saved to bookmarks'
            : 'Startup removed from bookmarks',
      ));
    } else if (event.type == 'investor') {
      final updated = loaded.investors.map((i) {
        return i.id == event.id ? i.copyWith(isSaved: isSaved) : i;
      }).toList();
      emit(loaded.copyWith(
        investors: updated,
        feedbackMessage: isSaved
            ? 'Investor saved to bookmarks'
            : 'Investor removed from bookmarks',
      ));
    } else if (event.type == 'founder') {
      final updated = loaded.founders.map((f) {
        return f.id == event.id ? f.copyWith(isSaved: isSaved) : f;
      }).toList();
      emit(loaded.copyWith(
        founders: updated,
        feedbackMessage: isSaved
            ? 'Founder saved to bookmarks'
            : 'Founder removed from bookmarks',
      ));
    } else if (event.type == 'event') {
      final updated = loaded.events.map((e) {
        return e.id == event.id ? e.copyWith(isSaved: isSaved) : e;
      }).toList();
      emit(loaded.copyWith(
        events: updated,
        feedbackMessage:
            isSaved ? 'Event saved to bookmarks' : 'Event removed from bookmarks',
      ));
    } else if (event.type == 'campaign') {
      final updated = loaded.campaigns.map((c) {
        return c.id == event.id ? c.copyWith(isSaved: isSaved) : c;
      }).toList();
      emit(loaded.copyWith(
        campaigns: updated,
        feedbackMessage: isSaved
            ? 'Campaign saved to bookmarks'
            : 'Campaign removed from bookmarks',
      ));
    }
  }

  Future<void> _onExpressInterest(
    ExpressInterestEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoadedState) return;
    final loaded = state as ExploreLoadedState;

    final result = await expressInterestUseCase(type: event.type, id: event.id);
    final isSent = result.rightOrNull;
    if (isSent == null) return;

    if (event.type == 'investor') {
      final updated = loaded.investors.map((i) {
        return i.id == event.id ? i.copyWith(isInterestSent: isSent) : i;
      }).toList();
      emit(loaded.copyWith(
        investors: updated,
        feedbackMessage:
            isSent ? 'Interest sent to investor!' : 'Interest withdrawn',
      ));
    } else if (event.type == 'founder') {
      final updated = loaded.founders.map((f) {
        return f.id == event.id ? f.copyWith(isInterestSent: isSent) : f;
      }).toList();
      emit(loaded.copyWith(
        founders: updated,
        feedbackMessage:
            isSent ? 'Interest sent to founder!' : 'Interest withdrawn',
      ));
    } else if (event.type == 'campaign') {
      final updated = loaded.campaigns.map((c) {
        return c.id == event.id ? c.copyWith(isInterested: isSent) : c;
      }).toList();
      emit(loaded.copyWith(
        campaigns: updated,
        feedbackMessage:
            isSent ? 'Added to investor opportunities!' : 'Interest withdrawn',
      ));
    } else if (event.type == 'startup') {
      final updated = loaded.startups.map((s) {
        return s.id == event.id ? s.copyWith(isInterested: isSent) : s;
      }).toList();
      emit(loaded.copyWith(
        startups: updated,
        feedbackMessage: isSent
            ? 'Interest expressed! The founder will be notified.'
            : 'Interest withdrawn.',
      ));
    }
  }

  Future<void> _onToggleEventRegistration(
    ToggleEventRegistrationEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoadedState) return;
    final loaded = state as ExploreLoadedState;

    final result = await toggleEventRegistrationUseCase(event.eventId);
    final isRegistered = result.rightOrNull;
    if (isRegistered == null) return;

    final updated = loaded.events.map((e) {
      if (e.id == event.eventId) {
        final count =
            isRegistered ? e.attendeesCount + 1 : e.attendeesCount - 1;
        return e.copyWith(
          isRegistered: isRegistered,
          attendeesCount: count > 0 ? count : 0,
        );
      }
      return e;
    }).toList();

    emit(loaded.copyWith(
      events: updated,
      feedbackMessage: isRegistered
          ? 'Successfully registered for event!'
          : 'Registration cancelled',
    ));
  }

  void _onFilterSavedCategory(
    FilterSavedCategoryEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      emit(loaded.copyWith(
        savedCategoryFilter: event.category,
        clearFeedback: true,
      ));
    }
  }

  void _onToggleCompareStartup(
    ToggleCompareStartupEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      final current = List<int>.from(loaded.selectedCompareIds);
      if (current.contains(event.startupId)) {
        if (current.length > 2) {
          current.remove(event.startupId);
        }
      } else {
        if (current.length < 3) {
          current.add(event.startupId);
        }
      }
      emit(loaded.copyWith(selectedCompareIds: current, clearFeedback: true));
    }
  }

  void _onSwitchRole(
    SwitchRoleEvent event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoadedState) {
      final loaded = state as ExploreLoadedState;
      emit(loaded.copyWith(
        userRole: event.role,
        selectedTabIndex: 0,
        clearFeedback: true,
      ));
    }
  }

  Future<void> _onToggleFollow(
    ToggleFollowEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoadedState) return;
    final loaded = state as ExploreLoadedState;

    final result = await toggleFollowUseCase(type: event.type, id: event.id);
    final isFollowing = result.rightOrNull;
    if (isFollowing == null) return;

    if (event.type == 'investor') {
      final updated = loaded.investors.map((i) {
        if (i.id == event.id) {
          final count = isFollowing
              ? i.followers + 1
              : (i.followers - 1).clamp(0, 999999);
          return i.copyWith(
            isFollowing: isFollowing,
            followers: count,
          );
        }
        return i;
      }).toList();
      emit(loaded.copyWith(
        investors: updated,
        feedbackMessage: isFollowing
            ? 'You are now following this investor!'
            : 'Unfollowed investor',
      ));
    } else if (event.type == 'founder') {
      final updated = loaded.founders.map((f) {
        if (f.id == event.id) {
          final count = isFollowing
              ? f.followers + 1
              : (f.followers - 1).clamp(0, 999999);
          return f.copyWith(
            isFollowing: isFollowing,
            followers: count,
          );
        }
        return f;
      }).toList();
      emit(loaded.copyWith(
        founders: updated,
        feedbackMessage: isFollowing
            ? 'You are now following this founder!'
            : 'Unfollowed founder',
      ));
    }
  }
}
