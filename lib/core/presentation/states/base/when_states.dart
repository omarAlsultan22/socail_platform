import 'package:cash_money/core/errors/exceptions/app_exception.dart';


abstract class WhenStates<T> {
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException error) onError,
  });
}