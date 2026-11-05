import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_founder_analytics_usecase.dart';
import '../../domain/usecases/get_investor_analytics_usecase.dart';
import '../../domain/usecases/get_startup_analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetFounderAnalyticsUseCase getFounderAnalyticsUseCase;
  final GetStartupAnalyticsUseCase getStartupAnalyticsUseCase;
  final GetInvestorAnalyticsUseCase getInvestorAnalyticsUseCase;

  AnalyticsBloc({
    required this.getFounderAnalyticsUseCase,
    required this.getStartupAnalyticsUseCase,
    required this.getInvestorAnalyticsUseCase,
  }) : super(const AnalyticsInitial()) {
    on<LoadFounderAnalyticsEvent>(_onLoadFounderAnalytics);
    on<LoadStartupAnalyticsEvent>(_onLoadStartupAnalytics);
    on<LoadInvestorAnalyticsEvent>(_onLoadInvestorAnalytics);
  }

  Future<void> _onLoadFounderAnalytics(
    LoadFounderAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await getFounderAnalyticsUseCase(event.period);
      emit(FounderAnalyticsLoaded(data: data, period: event.period));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadStartupAnalytics(
    LoadStartupAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await getStartupAnalyticsUseCase(event.period);
      emit(StartupAnalyticsLoaded(data: data, period: event.period));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadInvestorAnalytics(
    LoadInvestorAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await getInvestorAnalyticsUseCase(event.period);
      emit(InvestorAnalyticsLoaded(data: data, period: event.period));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
