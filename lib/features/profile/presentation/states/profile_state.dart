import '../../data/models/profile_success_state.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/user_info_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class ProfileState extends MainAppSupState {
  // ✅ State variables
  final int currentButtonScreen;

  // ✅ Friendship Button
  final String friendshipButtonKey;

  // ✅ State message
  final MessageResult messageResult;

  // ✅ User Info Data
  final UserInfoModel userInfoModel;

  // ✅ Pagination variables
  final DocumentSnapshot? lastFriendDoc;

  const ProfileState({
    this.lastFriendDoc,
    required super.subState,
    required this.messageResult,
    required this.userInfoModel,
    required this.currentButtonScreen,
    required this.friendshipButtonKey,
  });

  factory ProfileState.initial() {
    return ProfileState(
        lastFriendDoc: null,
        currentButtonScreen: 0,
        userInfoModel: UserInfoModel(),
        subState: const InitialState(),
        friendshipButtonKey: 'unfriend',
        messageResult: MessageResult.initial()
    );
  }

  UserInfoModel updateProfileInfo({
    String? userId,
    bool? isOnline,
    String? userState,
    PostModel? coverImage,
    PostModel? profileImage
  }) {
    return userInfoModel.copyWith(
      myId: userId,
      meIsOnline: isOnline,
      myState: userState,
      coverImage: coverImage,
      profileImage: profileImage,
    );
  }

  ProfileState copyWith({
    int? currentButtonScreen,
    MainAppSubState? subState,
    String? friendshipButtonKey,
    UserInfoModel? userInfoModel,
    MessageResult? messageResult,
  }) {
    return ProfileState(
        subState: subState ?? this.subState,
        userInfoModel: userInfoModel ?? this.userInfoModel,
        messageResult: messageResult ?? MessageResult.initial(),
        currentButtonScreen: currentButtonScreen ?? this.currentButtonScreen,
        friendshipButtonKey: friendshipButtonKey ?? this.friendshipButtonKey
    );
  }

  // ✅ Post modification functions

  UserInfoModel addPost(PostModel postModel) {
    if (postModel.pathType != AppStrings.image) return updateProfileInfo();

    if(postModel.isProfilePost) {
      if (userInfoModel.profileImageDocId == postModel.myDocId) {
        return updateProfileInfo(profileImage: postModel);
      }
      if (userInfoModel.coverImageDocId == postModel.myDocId) {
        return updateProfileInfo(coverImage: postModel);
      }
    }
    return updateProfileInfo();
  }

  UserInfoModel removePost(PostModel postModel) {
    if (postModel.pathType != AppStrings.image) return updateProfileInfo();
    if (userInfoModel.profileImageDocId == postModel.myDocId) {
      return updateProfileInfo(profileImage: postModel);
    }
    if (userInfoModel.profileImageDocId == postModel.myDocId) {
      return updateProfileInfo(coverImage: postModel);
    }
    return updateProfileInfo();
  }

  // ✅ State modification functions

  ProfileState setCurrentButton(int index) {
    return copyWith(currentButtonScreen: index);
  }

  ProfileState setIsRequest() {
    return copyWith(friendshipButtonKey: 'request');
  }

  ProfileState setIsFriend() {
    return copyWith(friendshipButtonKey: 'friend');
  }

  // ✅ State functions

  ProfileState setLoadingState() {
    return copyWith(subState: LoadingState());
  }

  ProfileState setSuccessState() {
    return copyWith(subState: SuccessState());
  }

  ProfileState setErrorState(AppException failure) {
    return copyWith(subState: ErrorState(failure: failure));
  }

  @override
  ProfileSuccessState get dataModels =>
      ProfileSuccessState(
          messageResult: messageResult,
          userInfoModel: userInfoModel,
          currentButtonScreen: currentButtonScreen,
          friendshipButtonKey: friendshipButtonKey
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(ProfileSuccessState) onLoaded,
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