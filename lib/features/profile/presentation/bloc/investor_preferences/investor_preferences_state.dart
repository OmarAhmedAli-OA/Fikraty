import 'package:equatable/equatable.dart';
import '../../../domain/entities/investor_preferences.dart';

abstract class InvestorPreferencesState extends Equatable {
  const InvestorPreferencesState();

  @override
  List<Object?> get props => [];
}

class InvestorPreferencesInitial extends InvestorPreferencesState {
  const InvestorPreferencesInitial();
}

class InvestorPreferencesLoading extends InvestorPreferencesState {
  const InvestorPreferencesLoading();
}

class InvestorPreferencesLoaded extends InvestorPreferencesState {
  final InvestorPreferences preferences;
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;

  const InvestorPreferencesLoaded({
    required this.preferences,
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
  });

  InvestorPreferencesLoaded copyWith({
    InvestorPreferences? preferences,
    bool? isSaving,
    String? successMessage,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return InvestorPreferencesLoaded(
      preferences: preferences ?? this.preferences,
      isSaving: isSaving ?? this.isSaving,
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [preferences, isSaving, successMessage, errorMessage];
}

class InvestorPreferencesError extends InvestorPreferencesState {
  final String message;
  const InvestorPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}
