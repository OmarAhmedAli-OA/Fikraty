import 'package:equatable/equatable.dart';
import '../../domain/entities/founder_analytics.dart';
import '../../domain/entities/investor_analytics.dart';
import '../../domain/entities/startup_analytics.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class FounderAnalyticsLoaded extends AnalyticsState {
  final FounderAnalytics data;
  final String period;

  const FounderAnalyticsLoaded({
    required this.data,
    required this.period,
  });

  @override
  List<Object?> get props => [data, period];
}

class StartupAnalyticsLoaded extends AnalyticsState {
  final StartupAnalytics data;
  final String period;

  const StartupAnalyticsLoaded({
    required this.data,
    required this.period,
  });

  @override
  List<Object?> get props => [data, period];
}

class InvestorAnalyticsLoaded extends AnalyticsState {
  final InvestorAnalytics data;
  final String period;

  const InvestorAnalyticsLoaded({
    required this.data,
    required this.period,
  });

  @override
  List<Object?> get props => [data, period];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
