import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/compare_startup_item.dart';
import '../entities/explore_campaign.dart';
import '../entities/explore_content_item.dart';
import '../entities/explore_event.dart';
import '../entities/explore_founder.dart';
import '../entities/explore_investor.dart';
import '../entities/explore_startup.dart';

abstract class ExploreRepository {
  Future<Either<Failure, List<ExploreStartup>>> getStartups();
  Future<Either<Failure, List<ExploreInvestor>>> getInvestors();
  Future<Either<Failure, List<ExploreFounder>>> getFounders();
  Future<Either<Failure, List<ExploreEvent>>> getEvents();
  Future<Either<Failure, List<ExploreCampaign>>> getCampaigns();
  Future<Either<Failure, List<CompareStartupItem>>> getCompareStartups();
  Future<Either<Failure, List<ExploreContentItem>>> getSavedContentItems();
  Future<Either<Failure, bool>> toggleBookmark(String type, int id);
  Future<Either<Failure, bool>> expressInterest(String type, int id);
  Future<Either<Failure, bool>> toggleEventRegistration(int eventId);
  Future<Either<Failure, bool>> toggleFollow(String type, int id);
}
