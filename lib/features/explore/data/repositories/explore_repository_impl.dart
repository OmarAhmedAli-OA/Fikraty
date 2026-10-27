import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/compare_startup_item.dart';
import '../../domain/entities/explore_campaign.dart';
import '../../domain/entities/explore_content_item.dart';
import '../../domain/entities/explore_event.dart';
import '../../domain/entities/explore_founder.dart';
import '../../domain/entities/explore_investor.dart';
import '../../domain/entities/explore_startup.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_local_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  const ExploreRepositoryImpl(this._localDataSource);

  final ExploreLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<ExploreStartup>>> getStartups() async {
    try {
      final items = await _localDataSource.getStartups();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreInvestor>>> getInvestors() async {
    try {
      final items = await _localDataSource.getInvestors();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreFounder>>> getFounders() async {
    try {
      final items = await _localDataSource.getFounders();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreEvent>>> getEvents() async {
    try {
      final items = await _localDataSource.getEvents();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreCampaign>>> getCampaigns() async {
    try {
      final items = await _localDataSource.getCampaigns();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompareStartupItem>>> getCompareStartups() async {
    try {
      final items = await _localDataSource.getCompareStartups();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreContentItem>>> getSavedContentItems() async {
    try {
      final items = await _localDataSource.getSavedContentItems();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBookmark(String type, int id) async {
    try {
      final result = await _localDataSource.toggleBookmark(type, id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> expressInterest(String type, int id) async {
    try {
      final result = await _localDataSource.expressInterest(type, id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleEventRegistration(int eventId) async {
    try {
      final result = await _localDataSource.toggleEventRegistration(eventId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFollow(String type, int id) async {
    try {
      final result = await _localDataSource.toggleFollow(type, id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
