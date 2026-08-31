import '../../../../core/data/models/user_model.dart';
import '../../../../core/presentation/states/app_sup_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class SearchState extends SingleModelAppState<List<UserModel>> {
  SearchState({
    required super.subState,
    required super.firstModel
  });

  factory SearchState.initial(){
    return SearchState(
        firstModel: [],
        subState: InitialState()
    );
  }

  @override
  SearchState copyWith({
    List<UserModel>? firstModel,
    MainAppSubState? subState
  }) {
    return SearchState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
    );
  }

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure));
  }
}