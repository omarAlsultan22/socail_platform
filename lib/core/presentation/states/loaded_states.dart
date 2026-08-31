import 'base/main_loaded_state.dart';


class SingleModelSuccessState<T> extends LoadedState {
  final T? firstModel;

  SingleModelSuccessState({
    required this.firstModel
  });
}


class DoubleModelSuccessState<T, U> extends LoadedState {
  final T? firstModel;
  final U? secondModel;

  DoubleModelSuccessState({
    required this.firstModel,
    required this.secondModel
  });
}

class TripleModelSuccessState<T, U, S> extends LoadedState {
  final T? firstModel;
  final U? secondModel;
  final S? thirdModel;

  TripleModelSuccessState({
    required this.firstModel,
    required this.secondModel,
    required this.thirdModel
  });
}




