import '../../../../core/data/models/profile_info_model.dart';
import '../../../../models/account_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class MenuState extends TripleModelAppState<UserAccount, ProfileInfoModel, MessageResult> {
  MenuState({
    super.firstModel,
    super.secondModel,
    super.thirdModel,
    required super.subState
  });

  factory MenuState.initial() {
    return MenuState(
      firstModel: null,
      secondModel: null,
      thirdModel: MessageResult.initial(),
      subState: InitialState(),
    );
  }

  @override
  MenuState copyWith({
    UserAccount? firstModel,
    ProfileInfoModel? secondModel,
    MessageResult? thirdModel,
    MainAppSubState? subState,
  }) {
    return MenuState(
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
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}