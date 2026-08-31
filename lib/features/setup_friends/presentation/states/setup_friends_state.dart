import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class SetupFriendsState extends TripleModelAppState<int, List<UserModel>, MessageResult> {
  SetupFriendsState({
    super.firstModel,
    super.secondModel,
    super.thirdModel,
    required super.subState
  });

  factory SetupFriendsState.initial() {
    return SetupFriendsState(
      firstModel: 0,
      secondModel: const [],
      thirdModel: MessageResult.initial(),
      subState: InitialState(),
    );
  }

  @override
  SetupFriendsState copyWith({
    int? firstModel,
    List<UserModel>? secondModel,
    MessageResult? thirdModel,
    MainAppSubState? subState,
  }) {
    return SetupFriendsState(
        subState: subState ?? this.subState,
        firstModel: firstModel ?? this.firstModel,
        secondModel: secondModel ?? this.secondModel,
        thirdModel: thirdModel ?? this.thirdModel
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
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}