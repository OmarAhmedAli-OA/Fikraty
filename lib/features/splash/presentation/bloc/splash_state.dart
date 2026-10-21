import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
// Later, you can split this into SplashAuthenticated and SplashUnauthenticated
class SplashSuccess extends SplashState {} 
class SplashFailure extends SplashState {
  final String message;
  const SplashFailure(this.message);

  @override
  List<Object> get props => [message];
}