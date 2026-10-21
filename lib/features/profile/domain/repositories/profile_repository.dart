import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/constants/countries.dart';
import '../entities/user_profile.dart';
import '../entities/investor_preferences.dart';
import '../entities/interest_item.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile({UserRole? role});

  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  Future<Either<Failure, UserProfile>> switchRole(UserRole newRole);

  Future<Either<Failure, UserProfile>> updateUserCountry(Country country);

  Future<Either<Failure, UserProfile>> addPost(String text);

  Future<Either<Failure, UserProfile>> togglePostLike(int postId);

  Future<Either<Failure, UserProfile>> uploadDocument(ProfileDocument document);

  Future<Either<Failure, UserProfile>> removeDocument(String documentId);

  Future<Either<Failure, InvestorPreferences>> getInvestorPreferences();

  Future<Either<Failure, InvestorPreferences>> updateInvestorPreferences(
      InvestorPreferences preferences);

  Future<Either<Failure, List<InterestItem>>> getInterests({
    required UserRole role,
    required InterestDirection direction,
  });

  Future<Either<Failure, InterestItem>> updateInterestStatus({
    required int interestId,
    required InterestStatus newStatus,
  });
}
