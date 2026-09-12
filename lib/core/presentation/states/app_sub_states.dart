import '../../errors/exceptions/base/app_exception.dart';
import 'base/main_app_sub_state.dart';


class InitialState implements MainAppSubState{
  const InitialState();
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onInitial();
  }
}


class LoadingState implements MainAppSubState{
  const LoadingState();
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onLoading();
  }
}


class SuccessState implements MainAppSubState {
  const SuccessState();
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onLoaded();
  }
}


class ErrorState implements MainAppSubState {
  final AppException failure;

  const ErrorState({
    required this.failure,
  });

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError
  }) {
    return onError(failure);
  }
}