import 'package:fikraty/features/explore/data/datasources/explore_local_data_source.dart';
import 'package:fikraty/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:fikraty/features/explore/domain/usecases/express_interest_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/get_explore_data_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_bookmark_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_event_registration_usecase.dart';
import 'package:fikraty/features/explore/domain/usecases/toggle_follow_usecase.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_event.dart';
import 'package:fikraty/features/explore/presentation/bloc/explore_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExploreLocalDataSourceImpl dataSource;
  late ExploreRepositoryImpl repository;
  late ExploreBloc bloc;

  setUp(() {
    dataSource = ExploreLocalDataSourceImpl();
    repository = ExploreRepositoryImpl(dataSource);
    bloc = ExploreBloc(
      getExploreDataUseCase: GetExploreDataUseCase(repository),
      toggleBookmarkUseCase: ToggleBookmarkUseCase(repository),
      expressInterestUseCase: ExpressInterestUseCase(repository),
      toggleEventRegistrationUseCase: ToggleEventRegistrationUseCase(repository),
      toggleFollowUseCase: ToggleFollowUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('toggle follow on investor persists and updates followers count in bloc and data source', () async {
    bloc.add(const LoadExploreDataEvent());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<ExploreLoadingState>(),
        isA<ExploreLoadedState>(),
      ]),
    );

    final loaded = bloc.state as ExploreLoadedState;
    final initialInvestor = loaded.investors.firstWhere((i) => i.id == 1);
    final initialCount = initialInvestor.followers;
    expect(initialInvestor.isFollowing, isFalse);

    // Follow first investor (id: 1)
    bloc.add(const ToggleFollowEvent(type: 'investor', id: 1));
    await expectLater(
      bloc.stream,
      emits(predicate<ExploreState>((state) {
        if (state is! ExploreLoadedState) return false;
        final inv = state.investors.firstWhere((i) => i.id == 1);
        return inv.isFollowing == true && inv.followers == initialCount + 1;
      })),
    );

    // Verify in data source
    final dataInvestors = await dataSource.getInvestors();
    expect(dataInvestors.firstWhere((i) => i.id == 1).isFollowing, isTrue);
    expect(dataInvestors.firstWhere((i) => i.id == 1).followers, initialCount + 1);

    // Unfollow
    bloc.add(const ToggleFollowEvent(type: 'investor', id: 1));
    await expectLater(
      bloc.stream,
      emits(predicate<ExploreState>((state) {
        if (state is! ExploreLoadedState) return false;
        final inv = state.investors.firstWhere((i) => i.id == 1);
        return inv.isFollowing == false && inv.followers == initialCount;
      })),
    );
  });

  test('toggle follow on founder increments followers and persists in bloc without exception', () async {
    bloc.add(const LoadExploreDataEvent());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<ExploreLoadingState>(),
        isA<ExploreLoadedState>(),
      ]),
    );

    final initialFounder = (bloc.state as ExploreLoadedState).founders.firstWhere((f) => f.id == 1);
    final initialCount = initialFounder.followers;
    expect(initialFounder.isFollowing, isFalse);

    // Follow founder
    bloc.add(const ToggleFollowEvent(type: 'founder', id: 1));
    await expectLater(
      bloc.stream,
      emits(predicate<ExploreState>((state) {
        if (state is! ExploreLoadedState) return false;
        final f = state.founders.firstWhere((f) => f.id == 1);
        return f.isFollowing == true && f.followers == initialCount + 1;
      })),
    );

    // Verify in data source
    final dataFounders = await dataSource.getFounders();
    final updated = dataFounders.firstWhere((f) => f.id == 1);
    expect(updated.isFollowing, isTrue);
    expect(updated.followers, initialCount + 1);
  });

  test('express interest in startup persists in bloc and data source without exception', () async {
    bloc.add(const LoadExploreDataEvent());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<ExploreLoadingState>(),
        isA<ExploreLoadedState>(),
      ]),
    );

    final initialStartup = (bloc.state as ExploreLoadedState).startups.firstWhere((s) => s.id == 1);
    expect(initialStartup.isInterested, isFalse);

    // Express interest
    bloc.add(const ExpressInterestEvent(type: 'startup', id: 1));
    await expectLater(
      bloc.stream,
      emits(predicate<ExploreState>((state) {
        if (state is! ExploreLoadedState) return false;
        return state.startups.firstWhere((s) => s.id == 1).isInterested == true;
      })),
    );

    // Verify in data source
    final dataStartups = await dataSource.getStartups();
    expect(dataStartups.firstWhere((s) => s.id == 1).isInterested, isTrue);

    // Re-fetch explore data: should retain interest and follow states
    bloc.add(const LoadExploreDataEvent(isRefresh: true));
    await expectLater(
      bloc.stream,
      emits(predicate<ExploreState>((state) {
        if (state is! ExploreLoadedState) return false;
        return state.startups.firstWhere((s) => s.id == 1).isInterested == true;
      })),
    );
  });
}
