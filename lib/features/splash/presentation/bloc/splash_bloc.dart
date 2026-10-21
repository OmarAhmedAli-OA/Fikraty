import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    try {
      // TODO: Inject your AuthRepository or SecureStorageManager here later
      // Simulating an initialization process (e.g., checking tokens)
      await Future.delayed(const Duration(seconds: 2));
      
      // Emit success when your initialization logic is complete
      emit(SplashSuccess());
    } catch (e) {
      emit(SplashFailure(e.toString()));
    }
  }
}