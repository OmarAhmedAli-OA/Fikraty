import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/compare_startup_item.dart';
import '../entities/explore_campaign.dart';
import '../entities/explore_content_item.dart';
import '../entities/explore_event.dart';
import '../entities/explore_founder.dart';
import '../entities/explore_investor.dart';
import '../entities/explore_startup.dart';
import '../repositories/explore_repository.dart';

class ExploreDataBundle {
  const ExploreDataBundle({
    required this.startups,
    required this.investors,
    required this.founders,
    required this.events,
    required this.campaigns,
    required this.compareStartups,
    required this.savedItems,
  });

  final List<ExploreStartup> startups;
  final List<ExploreInvestor> investors;
  final List<ExploreFounder> founders;
  final List<ExploreEvent> events;
  final List<ExploreCampaign> campaigns;
  final List<CompareStartupItem> compareStartups;
  final List<ExploreContentItem> savedItems;
}

class GetExploreDataUseCase {
  const GetExploreDataUseCase(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, ExploreDataBundle>> call() async {
    try {
      final startupsRes = await _repository.getStartups();
      final investorsRes = await _repository.getInvestors();
      final foundersRes = await _repository.getFounders();
      final eventsRes = await _repository.getEvents();
      final campaignsRes = await _repository.getCampaigns();
      final compareRes = await _repository.getCompareStartups();
      final savedRes = await _repository.getSavedContentItems();

      return Right(
        ExploreDataBundle(
          startups: startupsRes.rightOrNull ?? [],
          investors: investorsRes.rightOrNull ?? [],
          founders: foundersRes.rightOrNull ?? [],
          events: eventsRes.rightOrNull ?? [],
          campaigns: campaignsRes.rightOrNull ?? [],
          compareStartups: compareRes.rightOrNull ?? [],
          savedItems: savedRes.rightOrNull ?? [],
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
