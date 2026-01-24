abstract class BlocStates {}

class InitialState extends BlocStates {}

// General States //
class LoadingState extends InitialState {}

class SuccessState extends InitialState {}

class ErrorState extends InitialState {
  late String error;

  ErrorState(this.error);
}

// Global States //
class UpdateNewState extends InitialState {}
