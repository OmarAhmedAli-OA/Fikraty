import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/constants/countries.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/investor_preferences.dart';
import '../../domain/entities/interest_item.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_dummy_data_source.dart';
import '../models/user_profile_model.dart';
import '../models/investor_preferences_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  const ProfileRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile({UserRole? role}) async {
    try {
      final profileModel = await dataSource.getProfile(role: role);
      return Right(profileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final updatedModel = await dataSource.updateProfile(model);
      return Right(updatedModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> switchRole(UserRole newRole) async {
    try {
      final profile = await dataSource.switchRole(newRole);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to switch role: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserCountry(Country country) async {
    try {
      final profile = await dataSource.updateUserCountry(country);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update country: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> addPost(String text) async {
    try {
      final profile = await dataSource.addPost(text);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to publish post: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> togglePostLike(int postId) async {
    try {
      final profile = await dataSource.togglePostLike(postId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle like: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> uploadDocument(
      ProfileDocument document) async {
    try {
      final profile = await dataSource.uploadDocument(document);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to upload document: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> removeDocument(String documentId) async {
    try {
      final profile = await dataSource.removeDocument(documentId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to delete document: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InvestorPreferences>> getInvestorPreferences() async {
    try {
      final preferences = await dataSource.getInvestorPreferences();
      return Right(preferences);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load investor preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InvestorPreferences>> updateInvestorPreferences(
      InvestorPreferences preferences) async {
    try {
      final model = InvestorPreferencesModel.fromEntity(preferences);
      final updated = await dataSource.updateInvestorPreferences(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to save investor preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InterestItem>>> getInterests({
    required UserRole role,
    required InterestDirection direction,
  }) async {
    try {
      final interests =
          await dataSource.getInterests(role: role, direction: direction);
      return Right(interests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load interests: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InterestItem>> updateInterestStatus({
    required int interestId,
    required InterestStatus newStatus,
  }) async {
    try {
      final updated = await dataSource.updateInterestStatus(
        interestId: interestId,
        newStatus: newStatus,
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update interest status: ${e.toString()}'));
    }
  }
}
