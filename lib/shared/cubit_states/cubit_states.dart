abstract class CubitStates{}
class InitialState extends CubitStates{}
class LoadingState extends CubitStates{}
class SuccessState extends CubitStates{}
class RequestSuccessState extends CubitStates{}
class SuggestSuccessState extends CubitStates{}
class DeleteSuccessState extends CubitStates{}
class ListSuccessState<T> extends CubitStates{
  final List<T> modelsList;
  ListSuccessState({required this.modelsList});
}
class ModelSuccessState<T> extends CubitStates{
  final T model;
  ModelSuccessState({required this.model});
}
class ErrorState extends CubitStates{
  final String error;
  ErrorState(this.error);
}

class ChangeIndexState extends CubitStates{}
class CountUpdatedState extends CubitStates{}

