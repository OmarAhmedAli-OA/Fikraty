import 'package:equatable/equatable.dart';
import '../../../../core/constants/countries.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/interest_item.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final UserRole? role;
  const LoadProfileEvent({this.role});

  @override
  List<Object?> get props => [role];
}

class SwitchRoleEvent extends ProfileEvent {
  final UserRole newRole;
  const SwitchRoleEvent(this.newRole);

  @override
  List<Object?> get props => [newRole];
}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;
  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ChangeCountryEvent extends ProfileEvent {
  final Country country;
  const ChangeCountryEvent(this.country);

  @override
  List<Object?> get props => [country];
}

class AddPostEvent extends ProfileEvent {
  final String text;
  const AddPostEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ToggleLikePostEvent extends ProfileEvent {
  final int postId;
  const ToggleLikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class UploadDocumentEvent extends ProfileEvent {
  final ProfileDocument document;
  const UploadDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class RemoveDocumentEvent extends ProfileEvent {
  final String documentId;
  const RemoveDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class LoadInterestsEvent extends ProfileEvent {
  final InterestDirection direction;
  const LoadInterestsEvent({this.direction = InterestDirection.received});

  @override
  List<Object?> get props => [direction];
}

class UpdateInterestStatusEvent extends ProfileEvent {
  final int interestId;
  final InterestStatus newStatus;

  const UpdateInterestStatusEvent({
    required this.interestId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [interestId, newStatus];
}
