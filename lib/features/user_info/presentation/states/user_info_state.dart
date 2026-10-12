import '../../../../core/data/models/profile_info.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/user_info/data/models/user_info_success_state.dart';


class UserInfoState extends MainAppSupState {
  final MessageResult messageResult;
  final ProfileInfo? profileInfo;

  UserInfoState({
    this.profileInfo,
    required super.subState,
    required this.messageResult
  });

  factory UserInfoState.initial() {
    return UserInfoState(
        subState: InitialState(),
        profileInfo: ProfileInfo.initial(),
        messageResult: MessageResult.initial()
    );
  }

  ProfileInfo profileInfoCopyWith({
    String? userLive,
    String? userFrom,
    String? userWork,
    String? userState,
    String? userRelational,
  }) {
    return profileInfo!.copyWith(
        userWork: userWork,
        userLive: userLive,
        userFrom: userFrom,
        userState: userState,
        userRelational: userRelational
    );
  }

  UserInfoState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    ProfileInfo? profileInfo,
  }) {
    return UserInfoState(
        subState: subState ?? this.subState,
        messageResult: messageResult ?? MessageResult.initial(),
        profileInfo: profileInfo ?? this.profileInfo
    );
  }

  @override
  UserInfoSuccessState get dataModels =>
      UserInfoSuccessState(
          messageResult: messageResult,
          profileInfoModel: profileInfo!
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(UserInfoSuccessState) onLoaded,
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