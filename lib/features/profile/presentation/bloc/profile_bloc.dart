import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/interest_item.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/switch_role.dart';
import '../../domain/usecases/get_interests.dart';
import '../../domain/usecases/update_interest_status.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SwitchRoleUseCase switchRoleUseCase;
  final GetInterestsUseCase getInterestsUseCase;
  final UpdateInterestStatusUseCase updateInterestStatusUseCase;
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.switchRoleUseCase,
    required this.getInterestsUseCase,
    required this.updateInterestStatusUseCase,
    required this.profileRepository,
  }) : super(const ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SwitchRoleEvent>(_onSwitchRole);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangeCountryEvent>(_onChangeCountry);
    on<AddPostEvent>(_onAddPost);
    on<ToggleLikePostEvent>(_onToggleLikePost);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<RemoveDocumentEvent>(_onRemoveDocument);
    on<LoadInterestsEvent>(_onLoadInterests);
    on<UpdateInterestStatusEvent>(_onUpdateInterestStatus);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());

    final profileResult = await getProfileUseCase(role: event.role);

    profileResult.fold(
      (failure) => emit(ProfileErrorState(failure.message)),
      (profile) {
        emit(ProfileLoadedState(profile: profile));
        add(const LoadInterestsEvent(direction: InterestDirection.received));
      },
    );
  }

  Future<void> _onSwitchRole(
    SwitchRoleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    emit(currentState.copyWith(isSaving: true, clearMessage: true));

    final result = await switchRoleUseCase(event.newRole);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (newProfile) {
        emit(currentState.copyWith(
          profile: newProfile,
          isSaving: false,
          successMessage:
              'Switched to ${newProfile.role == UserRole.entrepreneur ? 'Founder' : 'Investor'} view',
        ));
        add(LoadInterestsEvent(
            direction: currentState.currentInterestDirection));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    emit(currentState.copyWith(isSaving: true, clearMessage: true));

    final result = await updateProfileUseCase(event.profile);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (updatedProfile) => emit(currentState.copyWith(
        profile: updatedProfile,
        isSaving: false,
        successMessage: 'Changes saved successfully!',
      )),
    );
  }

  Future<void> _onChangeCountry(
    ChangeCountryEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final currentProfile = currentState.profile;
    final updatedProfile = currentProfile.copyWith(
      country: event.country,
      location:
          '${currentProfile.location.split(',').first.trim()}, ${event.country.name}',
    );

    add(UpdateProfileEvent(updatedProfile));
  }

  Future<void> _onAddPost(
    AddPostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await profileRepository.addPost(event.text);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedProfile) => emit(currentState.copyWith(
        profile: updatedProfile,
        successMessage: 'Post published!',
      )),
    );
  }

  Future<void> _onToggleLikePost(
    ToggleLikePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await profileRepository.togglePostLike(event.postId);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedProfile) => emit(currentState.copyWith(
        profile: updatedProfile,
      )),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await profileRepository.uploadDocument(event.document);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedProfile) => emit(currentState.copyWith(
        profile: updatedProfile,
        successMessage: 'Document uploaded successfully!',
      )),
    );
  }

  Future<void> _onRemoveDocument(
    RemoveDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await profileRepository.removeDocument(event.documentId);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedProfile) => emit(currentState.copyWith(
        profile: updatedProfile,
        successMessage: 'Document removed.',
      )),
    );
  }

  Future<void> _onLoadInterests(
    LoadInterestsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await getInterestsUseCase(
      role: currentState.profile.role,
      direction: event.direction,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (interests) => emit(currentState.copyWith(
        interests: interests,
        currentInterestDirection: event.direction,
      )),
    );
  }

  Future<void> _onUpdateInterestStatus(
    UpdateInterestStatusEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final currentState = state as ProfileLoadedState;

    final result = await updateInterestStatusUseCase(
      interestId: event.interestId,
      newStatus: event.newStatus,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedItem) {
        final updatedList = currentState.interests.map((item) {
          return item.id == updatedItem.id ? updatedItem : item;
        }).toList();

        final statusText = updatedItem.status == InterestStatus.accepted
            ? 'Interest accepted!'
            : 'Interest declined';

        emit(currentState.copyWith(
          interests: updatedList,
          successMessage: statusText,
        ));
      },
    );
  }
}
