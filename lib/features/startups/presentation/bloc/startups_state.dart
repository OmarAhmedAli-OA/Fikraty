import 'package:equatable/equatable.dart';
import '../../domain/entities/startups.dart';

sealed class StartupsState extends Equatable {
  const StartupsState();

  @override
  List<Object?> get props => [];
}

final class StartupsInitialState extends StartupsState {
  const StartupsInitialState();
}

final class StartupsLoadingState extends StartupsState {
  const StartupsLoadingState();
}

final class StartupsLoadedState extends StartupsState {
  const StartupsLoadedState(this.startup);

  /// Nullable because the entrepreneur may not have created a startup yet
  final StartupEntity? startup;

  bool get hasStartup => startup != null;

  @override
  List<Object?> get props => [startup];
}

final class StartupActionSuccessState extends StartupsState {
  const StartupActionSuccessState({
    required this.startup,
    required this.message,
  });

  final StartupEntity startup;
  final String message;

  @override
  List<Object?> get props => [startup, message];
}

final class StartupsErrorState extends StartupsState {
  const StartupsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
