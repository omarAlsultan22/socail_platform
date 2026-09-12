import '../../../../core/data/models/user_model.dart';
import '../../data/models/setup_friends_success_state.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class SetupFriendsState extends MainAppSupState {
  final int friendsNumber;
  final List<UserModel> friendsList;
  final MessageResult messageResult;

  const SetupFriendsState({
    required super.subState,
    required this.friendsNumber,
    required this.friendsList,
    required this.messageResult,
  });

  factory SetupFriendsState.initial() {
    return SetupFriendsState(
      friendsNumber: 0,
      friendsList: const [],
      messageResult: MessageResult.initial(),
      subState: InitialState(),
    );
  }

  @override
  SetupFriendsSuccessState get dataModels =>
      SetupFriendsSuccessState(
          friendsNumber: friendsNumber,
          friendsList: friendsList,
          messageResult: messageResult
      );

  SetupFriendsState copyWith({
    int? friendsNumber,
    List<UserModel>? friendsList,
    MessageResult? messageResult,
    MainAppSubState? subState,
  }) {
    return SetupFriendsState(
        subState: subState ?? this.subState,
        friendsNumber: friendsNumber ?? this.friendsNumber,
        friendsList: friendsList ?? this.friendsList,
        messageResult: messageResult ?? this.messageResult
    );
  }

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(SetupFriendsSuccessState) onLoaded,
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
