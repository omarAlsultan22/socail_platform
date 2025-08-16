abstract class CubitStates<T>{
  final List<T>? modelsList;
  final T? model;
  final String? error;
  final String? key;
  CubitStates({this.modelsList, this.model, this.error, this.key});
}
class InitialState extends CubitStates{}
class LoadingState extends CubitStates{
  LoadingState({super.key});
}
class SuccessState extends CubitStates{
  SuccessState({super.key});
}

class ListSuccessState<T> extends CubitStates{
  ListSuccessState({super.modelsList, super.key});
}
class ModelSuccessState<T> extends CubitStates{
  ModelSuccessState({super.model, super.key});
}
class ErrorState extends CubitStates{
  ErrorState({super.error, super.key});
}

class ChangeIndexState extends CubitStates{}
class CountUpdatedState extends CubitStates{}

