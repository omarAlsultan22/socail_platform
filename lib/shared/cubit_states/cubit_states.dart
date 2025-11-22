import '../constants/state_keys.dart';


abstract class CubitStates<T>{
  final List<T>? modelsList;
  final T? model;
  final String? error;
  final StatesKeys? stateKey;
  CubitStates({this.modelsList, this.model, this.error, this.stateKey});
}

class InitialState<T> extends CubitStates<T>{
  InitialState() : super();
}

class LoadingState<T> extends CubitStates<T>{
  LoadingState({super.stateKey});
}

class SuccessState<T> extends CubitStates<T> {
  final T? model;
  final List<T>? modelsList;

  SuccessState.empty({super.stateKey})
      : model = null,
        modelsList = null;

  SuccessState.withModel({required T this.model, super.stateKey})
      : modelsList = null;

  SuccessState.withList({required List<T> this.modelsList, super.stateKey})
      : model = null;
}

class ErrorState<T> extends CubitStates<T>{
  ErrorState({super.error, super.stateKey});
}

class ChangeIndexState<T> extends CubitStates<T>{
  ChangeIndexState() : super();
}

class CountUpdatedState<T> extends CubitStates<T>{
  CountUpdatedState() : super();
}
