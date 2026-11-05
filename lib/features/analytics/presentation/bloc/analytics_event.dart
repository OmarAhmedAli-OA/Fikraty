import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFounderAnalyticsEvent extends AnalyticsEvent {
  final String period;

  const LoadFounderAnalyticsEvent({this.period = '30D'});

  @override
  List<Object?> get props => [period];
}

class LoadStartupAnalyticsEvent extends AnalyticsEvent {
  final String period;

  const LoadStartupAnalyticsEvent({this.period = '30D'});

  @override
  List<Object?> get props => [period];
}

class LoadInvestorAnalyticsEvent extends AnalyticsEvent {
  final String period;

  const LoadInvestorAnalyticsEvent({this.period = '30D'});

  @override
  List<Object?> get props => [period];
}
