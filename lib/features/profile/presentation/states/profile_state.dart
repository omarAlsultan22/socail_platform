import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/new/friend_button.dart';
import '../../cubit.dart';
import '../../data/models/profile_success_state.dart';
import '../widgets/layouts/photos_screen.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';

import '../widgets/layouts/posts_screen.dart';
import '../widgets/layouts/videos_screen.dart';


class ProfileState extends MainAppSupState{
  final List<PostModel> postsDataList;
  final List<PostModel> usersProfileDataList;
  final List<PostModel> imagesList;
  final List<PostModel> videosList;
  final List<PostModel> profileImagesList;
  final List<PostModel> coverImagesList;

  // ✅ Album Data
  final List<AlbumsButtons> albumsButtons;
  final List<ImagesScreen> albumsScreens;

  // ✅ Friends' Data
  final List<UserModel> friendsList;

  // ✅ State message
  final MessageResult messageResult;

  // ✅ Profile Info Data
  final ProfileInfoModel? profileInfoModel;

  // ✅ Friend Button
  final FriendButton friendButton;

  // ✅ Pagination variables
  final DocumentSnapshot? lastPostDoc;
  final DocumentSnapshot? lastVideoDoc;
  final DocumentSnapshot? lastFriendDoc;
  final DocumentSnapshot? lastCoverImageDoc;
  final DocumentSnapshot? lastProfileImageDoc;

  // ✅ State variables
  final String uId;
  final String userId;
  final int currentButton;
  final int currentIndex;
  final bool isLoadingMore;
  final bool hasMorePosts;
  final bool hasMoreVideos;
  final bool hasMoreFriends;
  final bool hasMoreProfileImages;
  final bool hasMoreCoverImages;

  // ✅ Button lists (fixed)
  final List<ButtonModel> buttons;
  final List<void Function()> listenerScreens;

  const ProfileState({
    required super.subState,
    required this.messageResult,
    required this.friendButton
    this.profileInfoModel,
    this.postsDataList = const [],
    this.usersProfileDataList = const [],
    this.imagesList = const [],
    this.videosList = const [],
    this.profileImagesList = const [],
    this.coverImagesList = const [],
    this.albumsButtons = const [],
    this.albumsScreens = const [],
    this.friendsList = const [],
    this.lastPostDoc,
    this.lastVideoDoc,
    this.lastFriendDoc,
    this.lastProfileImageDoc,
    this.lastCoverImageDoc,
    this.uId = '',
    this.userId = '',
    this.currentButton = 0,
    this.currentIndex = 0,
    this.isLoadingMore = true,
    this.hasMorePosts = false,
    this.hasMoreVideos = false,
    this.hasMoreFriends = false,
    this.hasMoreProfileImages = false,
    this.hasMoreCoverImages = false,
    this.buttons = const [],
    this.listenerScreens = const [],
  });

  factory ProfileState.initial() {
    return ProfileState(
      friendButton: FriendButton(
          buttonName: 'Add Friend',
          backgroundColor: Colors.blue.shade900,
          textColor: Colors.white,
          onPressed: () =>
              widget.insertFriendsRequests(_uId);
      ),
      profileInfoModel: null,
      listenerScreens: [],
      subState: const InitialState(),
      messageResult: MessageResult.initial(),
      albumsButtons: [
        AlbumsButtons(id: 0, albumImage: null, albumText: 'posts Images'),
        AlbumsButtons(id: 1, albumImage: null, albumText: 'Profile Pictures'),
        AlbumsButtons(id: 2, albumImage: null, albumText: 'Cover Photos'),
      ],
      albumsScreens: [
        ImagesScreen(postModelList: [], titleName: 'Posts Images'),
        ImagesScreen(postModelList: [], titleName: 'Profile Pictures'),
        ImagesScreen(postModelList: [], titleName: 'Cover Photos'),
      ],
      buttons: [
        ButtonModel(id: 0, label: 'posts'),
        ButtonModel(id: 1, label: 'photos'),
        ButtonModel(id: 2, label: 'videos')
      ],
    );
  }

  ProfileInfoModel updateProfileInfo({
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

  ProfileState copyWith({
    ProfileInfoModel? profileInfo,
    List<PostModel>? secondModel,
    List<UserModel>? thirdModel,
    FriendButton friendButton,
    String? uId,
    String? userId,
    int? currentButton,
    int? currentIndex,
    bool? isLoadingMore,
    bool? hasMorePosts,
    bool? hasMoreVideos,
    bool? hasMoreProfileImages,
    bool? hasMoreCoverImages,
    List<ButtonModel>? buttons,
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<PostModel>? postsDataList,
    List<PostModel>? usersProfileDataList,
    List<PostModel>? imagesList,
    List<PostModel>? videosList,
    List<PostModel>? profileImagesList,
    List<PostModel>? coverImagesList,
    List<AlbumsButtons>? albumsButtons,
    List<ImagesScreen>? albumsScreens,
    List<UserModel>? friendsList,
    DocumentSnapshot? lastPostDoc,
    DocumentSnapshot? lastVideoDoc,
    DocumentSnapshot? lastProfileImageDoc,
    DocumentSnapshot? lastCoverImageDoc,
    List<void Function()>? listenerScreens
  }) {
    return ProfileState(
      subState: subState ?? this.subState,
      messageResult: messageResult ?? this.messageResult,
      postsDataList: postsDataList ?? this.postsDataList,
      usersProfileDataList: usersProfileDataList ?? this.usersProfileDataList,
      imagesList: imagesList ?? this.imagesList,
      videosList: videosList ?? this.videosList,
      profileImagesList: profileImagesList ?? this.profileImagesList,
      coverImagesList: coverImagesList ?? this.coverImagesList,
      albumsButtons: albumsButtons ?? this.albumsButtons,
      albumsScreens: albumsScreens ?? this.albumsScreens,
      friendsList: friendsList ?? this.friendsList,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      lastVideoDoc: lastVideoDoc ?? this.lastVideoDoc,
      lastProfileImageDoc: lastProfileImageDoc ?? this.lastProfileImageDoc,
      lastCoverImageDoc: lastCoverImageDoc ?? this.lastCoverImageDoc,
      uId: uId ?? this.uId,
      userId: userId ?? this.userId,
      currentButton: currentButton ?? this.currentButton,
      currentIndex: currentIndex ?? this.currentIndex,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      hasMoreProfileImages: hasMoreProfileImages ?? this.hasMoreProfileImages,
      hasMoreCoverImages: hasMoreCoverImages ?? this.hasMoreCoverImages,
      buttons: buttons ?? this.buttons,
      listenerScreens: listenerScreens ?? this.listenerScreens,
    );
  }

  // ✅ Post modification functions

  ProfileState addPost(PostModel post) {
    return copyWith(
      postsDataList: [post, ...postsDataList],
      subState: const SuccessState(),
    );
  }

  ProfileState removePost(String postId) {
    return copyWith(
      postsDataList: postsDataList.where((p) => p.docId != postId).toList(),
      subState: const SuccessState(),
    );
  }

  ProfileState updatePostsDataList(List<PostModel> newPosts, {bool append = false}) {
    final updatedPosts = append ? [...postsDataList, ...newPosts] : newPosts;
    return copyWith(postsDataList: updatedPosts);
  }

  ProfileState updateLastPostDoc(DocumentSnapshot? doc) {
    return copyWith(lastPostDoc: doc);
  }

  ProfileState setHasMorePosts(bool hasMore) {
    return copyWith(hasMorePosts: hasMore);
  }

  // ✅ Image and Story editing functions

  ProfileState addProfileImage(PostModel image) {
    return copyWith(
      profileImagesList: [image, ...profileImagesList],
    );
  }

  ProfileState addCoverImage(PostModel image) {
    return copyWith(
      coverImagesList: [image, ...coverImagesList],
    );
  }

  ProfileState updateProfileImagesList(List<PostModel> newImages, {bool append = false}) {
    final updatedImages = append ? [...profileImagesList, ...newImages] : newImages;
    return copyWith(profileImagesList: updatedImages);
  }

  ProfileState updateCoverImagesList(List<PostModel> newImages, {bool append = false}) {
    final updatedImages = append ? [...coverImagesList, ...newImages] : newImages;
    return copyWith(coverImagesList: updatedImages);
  }

  ProfileState updateVideosList(List<PostModel> newVideos, {bool append = false}) {
    final updatedVideos = append ? [...videosList, ...newVideos] : newVideos;
    return copyWith(videosList: updatedVideos);
  }

  ProfileState updateLastProfileImageDoc(DocumentSnapshot? doc) {
    return copyWith(lastVideoDoc: doc);
  }

  ProfileState updateLastCoverImageDoc(DocumentSnapshot? doc) {
    return copyWith(lastCoverImageDoc: doc);
  }

  ProfileState updateLastVideoDoc(DocumentSnapshot? doc) {
    return copyWith(lastCoverImageDoc: doc);
  }

  ProfileState setHasMoreProfileImages(bool hasMore) {
    return copyWith(hasMoreProfileImages: hasMore);
  }

  ProfileState setHasMoreCoverImages(bool hasMore) {
    return copyWith(hasMoreCoverImages: hasMore);
  }

  ProfileState setHasMoreVideos(bool hasMore) {
    return copyWith(hasMoreVideos: hasMore);
  }

  // ✅ Album modification functions

  ProfileState updateAlbumImage(int albumId, PostModel? image) {
    final updatedButtons = List<AlbumsButtons>.from(albumsButtons);
    final index = updatedButtons.indexWhere((b) => b.id == albumId);
    if (index != -1) {
      updatedButtons[index] = AlbumsButtons(
        id: updatedButtons[index].id,
        albumImage: image,
        albumText: updatedButtons[index].albumText,
      );
    }
    return copyWith(albumsButtons: updatedButtons);
  }

  ProfileState updateAlbumScreenList(int albumId, List<PostModel> postsList) {
    final updatedScreens = List<ImagesScreen>.from(albumsScreens);
    if (albumId < updatedScreens.length) {
      updatedScreens[albumId] = ImagesScreen(
        postModelList: postsList,
        titleName: updatedScreens[albumId].titleName,
      );
    }
    return copyWith(albumsScreens: updatedScreens);
  }

  // ✅ User-specific modification functions

  ProfileState setUserId(String id) {
    return copyWith(userId: id);
  }

  ProfileState setUId(String id) {
    return copyWith(uId: id);
  }

  ProfileState updateProfileImage(PostModel image) {
    final updatedInfo = profileInfoModel!.copyWith(profileImage: image);
    return copyWith(profileInfo: updatedInfo);
  }

  ProfileState updateCoverImage(PostModel image) {
    final updatedInfo = profileInfoModel!.copyWith(coverImage: image);
    return copyWith(profileInfo: updatedInfo);
  }

  // ✅ Friend modification functions

  ProfileState updateFriendsList(List<UserModel> friends) {
    return copyWith(thirdModel: friends, friendsList: friends);
  }

  // ✅ State modification functions

  ProfileState setCurrentIndex(int index) {
    return copyWith(currentIndex: index);
  }

  ProfileState setCurrentButton(int index, String uid) {
    return copyWith(currentButton: index, uId: uid);
  }

  ProfileState setIsRequest(bool value) {
    return copyWith(isRequest: value);
  }

  ProfileState setIsFriend(bool value) {
    return copyWith(isFriend: value);
  }

  ProfileState setIsLoadingMore(bool value) {
    return copyWith(isLoadingMore: value);
  }

  ProfileState setListenerScreens(List<void Function()> listeners) {
    return copyWith(listenerScreens: listeners);
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

  // ✅ Getters
  List<UserModel> get friends => friendsList;

  @override
  ProfileSuccessState get dataModels =>
      ProfileSuccessState(
        firstModel: profileInfo,
        secondModel: secondModel ?? const [],
        thirdModel: thirdModel ?? const [],
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