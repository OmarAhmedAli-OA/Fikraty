import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/interest_item.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final UserProfile profile;
  final List<InterestItem> interests;
  final InterestDirection currentInterestDirection;
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;

  const ProfileLoadedState({
    required this.profile,
    this.interests = const [],
    this.currentInterestDirection = InterestDirection.received,
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
  });

  ProfileLoadedState copyWith({
    UserProfile? profile,
    List<InterestItem>? interests,
    InterestDirection? currentInterestDirection,
    bool? isSaving,
    String? successMessage,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return ProfileLoadedState(
      profile: profile ?? this.profile,
      interests: interests ?? this.interests,
      currentInterestDirection:
          currentInterestDirection ?? this.currentInterestDirection,
      isSaving: isSaving ?? this.isSaving,
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        profile,
        interests,
        currentInterestDirection,
        isSaving,
        successMessage,
        errorMessage,
      ];
}

class ProfileErrorState extends ProfileState {
  final String message;
  const ProfileErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
