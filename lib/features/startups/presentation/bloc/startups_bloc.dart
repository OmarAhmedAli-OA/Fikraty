import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/startups_repository.dart';
import '../../domain/usecases/create_startups.dart';
import '../../domain/usecases/get_startups.dart';
import '../../domain/usecases/update_startups.dart';
import '../bloc/startups_event.dart';
import '../bloc/startups_state.dart';

class StartupsBloc extends Bloc<StartupsEvent, StartupsState> {
  StartupsBloc({
    required StartupsRepository repository,
  })  : _getMyStartupUseCase = GetMyStartupUseCase(repository),
        _saveStartupUseCase = SaveStartupUseCase(repository),
        _submitVerificationUseCase =
            SubmitStartupVerificationUseCase(repository),
        super(const StartupsInitialState()) {
    on<LoadMyStartupEvent>(_onLoadMyStartup);
    on<SaveStartupEvent>(_onSaveStartup);
    on<SubmitVerificationEvent>(_onSubmitVerification);
  }

  final GetMyStartupUseCase _getMyStartupUseCase;
  final SaveStartupUseCase _saveStartupUseCase;
  final SubmitStartupVerificationUseCase _submitVerificationUseCase;

  Future<void> _onLoadMyStartup(
    LoadMyStartupEvent event,
    Emitter<StartupsState> emit,
  ) async {
    emit(const StartupsLoadingState());
    try {
      final startup = await _getMyStartupUseCase();
      emit(StartupsLoadedState(startup));
    } catch (e) {
      emit(StartupsErrorState('Failed to load startup profile: $e'));
    }
  }

  Future<void> _onSaveStartup(
    SaveStartupEvent event,
    Emitter<StartupsState> emit,
  ) async {
    emit(const StartupsLoadingState());
    try {
      final savedStartup = await _saveStartupUseCase(event.startup);
      emit(StartupActionSuccessState(
        startup: savedStartup,
        message: event.isEditing
            ? 'Startup profile updated successfully!'
            : 'Startup profile saved and published successfully!',
      ));
      emit(StartupsLoadedState(savedStartup));
    } catch (e) {
      emit(StartupsErrorState('Failed to save startup profile: $e'));
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerificationEvent event,
    Emitter<StartupsState> emit,
  ) async {
    emit(const StartupsLoadingState());
    try {
      await _submitVerificationUseCase(
        startupId: event.startupId,
        documentType: event.documentType,
        registrationNumber: event.registrationNumber,
        note: event.note,
      );
      final updated = await _getMyStartupUseCase();
      emit(StartupActionSuccessState(
        startup: updated!,
        message: 'Verification request submitted for review successfully!',
      ));
      emit(StartupsLoadedState(updated));
    } catch (e) {
      emit(StartupsErrorState('Failed to submit verification request: $e'));
    }
  }
}
