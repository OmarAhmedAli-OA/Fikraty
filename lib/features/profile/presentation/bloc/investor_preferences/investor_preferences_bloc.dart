import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_investor_preferences.dart';
import '../../../domain/usecases/update_investor_preferences.dart';
import 'investor_preferences_event.dart';
import 'investor_preferences_state.dart';

class InvestorPreferencesBloc
    extends Bloc<InvestorPreferencesEvent, InvestorPreferencesState> {
  final GetInvestorPreferencesUseCase getInvestorPreferencesUseCase;
  final UpdateInvestorPreferencesUseCase updateInvestorPreferencesUseCase;

  InvestorPreferencesBloc({
    required this.getInvestorPreferencesUseCase,
    required this.updateInvestorPreferencesUseCase,
  }) : super(const InvestorPreferencesInitial()) {
    on<LoadInvestorPreferencesEvent>(_onLoadPreferences);
    on<UpdateInvestorPreferencesEvent>(_onUpdatePreferences);
  }

  Future<void> _onLoadPreferences(
    LoadInvestorPreferencesEvent event,
    Emitter<InvestorPreferencesState> emit,
  ) async {
    emit(const InvestorPreferencesLoading());
    final result = await getInvestorPreferencesUseCase();

    result.fold(
      (failure) => emit(InvestorPreferencesError(failure.message)),
      (preferences) =>
          emit(InvestorPreferencesLoaded(preferences: preferences)),
    );
  }

  Future<void> _onUpdatePreferences(
    UpdateInvestorPreferencesEvent event,
    Emitter<InvestorPreferencesState> emit,
  ) async {
    if (state is! InvestorPreferencesLoaded) return;
    final currentState = state as InvestorPreferencesLoaded;

    emit(currentState.copyWith(isSaving: true, clearMessage: true));

    final result =
        await updateInvestorPreferencesUseCase(event.preferences);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(currentState.copyWith(
        preferences: updated,
        isSaving: false,
        successMessage: 'Preferences saved — your matches will update',
      )),
    );
  }
}
