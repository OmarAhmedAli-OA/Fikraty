import 'package:equatable/equatable.dart';
import '../../domain/entities/startups.dart';

sealed class StartupsEvent extends Equatable {
  const StartupsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMyStartupEvent extends StartupsEvent {
  const LoadMyStartupEvent();
}

final class SaveStartupEvent extends StartupsEvent {
  const SaveStartupEvent(this.startup, {this.isEditing = false});

  final StartupEntity startup;
  final bool isEditing;

  @override
  List<Object?> get props => [startup, isEditing];
}

final class SubmitVerificationEvent extends StartupsEvent {
  const SubmitVerificationEvent({
    required this.startupId,
    required this.documentType,
    required this.registrationNumber,
    this.note,
  });

  final String startupId;
  final String documentType;
  final String registrationNumber;
  final String? note;

  @override
  List<Object?> get props => [startupId, documentType, registrationNumber, note];
}

final class ResetStartupEvent extends StartupsEvent {
  const ResetStartupEvent();
}
