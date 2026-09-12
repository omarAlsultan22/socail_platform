import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/user_info/data/models/user_info_success_state.dart';


class UserInfoState extends MainAppSupState {
  final MessageResult messageResult;
  final ProfileInfoModel? profileInfoModel;
  UserInfoState({
    this.profileInfoModel,
    required super.subState,
    required this.messageResult
  });

  factory UserInfoState.initial() {
    return UserInfoState(
      profileInfoModel: null,
      messageResult: MessageResult.initial(),
      subState: InitialState(),
    );
  }

  ProfileInfoModel profileInfoCopyWith({
    String? userId,
    bool? isOnline,
    String? userName,
    String? userLive,
    String? userFrom,
    String? userWork,
    String? userState,
    PostModel? coverImage,
    String? userRelational,
    PostModel? profileImage,
  }) {
    return profileInfoModel!.copyWith(
        userId: userId,
        userName: userName,
        userWork: userWork,
        userLive: userLive,
        userFrom: userFrom,
        isOnline: isOnline,
        userState: userState,
        coverImage: coverImage,
        profileImage: profileImage,
        userRelational: userRelational
    );
  }

  UserInfoState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    ProfileInfoModel? profileInfoModel,
  }) {
    return UserInfoState(
        subState: subState ?? this.subState,
        messageResult: messageResult ??  MessageResult.initial(),
        profileInfoModel: profileInfoModel ?? this.profileInfoModel
    );
  }

  @override
  UserInfoSuccessState get dataModels => UserInfoSuccessState(
      messageResult: messageResult,
      profileInfoModel: profileInfoModel!
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