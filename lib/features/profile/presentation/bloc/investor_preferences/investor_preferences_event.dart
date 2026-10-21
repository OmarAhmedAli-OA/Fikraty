import 'package:equatable/equatable.dart';
import '../../../domain/entities/investor_preferences.dart';

abstract class InvestorPreferencesEvent extends Equatable {
  const InvestorPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvestorPreferencesEvent extends InvestorPreferencesEvent {
  const LoadInvestorPreferencesEvent();
}

class UpdateInvestorPreferencesEvent extends InvestorPreferencesEvent {
  final InvestorPreferences preferences;
  const UpdateInvestorPreferencesEvent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
