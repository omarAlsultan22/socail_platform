import 'dart:async';
import '../states/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile_layout/posts_screen.dart';
import '../../profile_layout/photos_screen.dart';
import '../../profile_layout/videos_screen.dart';
import '../../domain/useCases/profile_useCase.dart';
import '../../../../shared/constants/state_keys.dart';
import '../../../../core/constants/user_details.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class ProfileCubit extends Cubit<ProfileState> with ErrorHandlerMixin<ProfileState>{check if method need error exception
  final ProfileUseCases _useCases;

  ProfileCubit({required ProfileUseCases useCases})
      : _useCases = useCases,
        super(ProfileState.initial()) {
    // إعداد الـ listenerScreens بعد الإنشاء
    emit(state.copyWith(
      listenerScreens: [
        _loadMorePosts,
        _loadMoreProfileImages,
        _loadMoreCoverImages,
      ],
    ));
  }

  static ProfileCubit get(context, {ValueKey<String>? key}) => BlocProvider.of(context);

  List<Widget> get buttonsScreens => [
    PostsScreen(profileCubit: this),
    PhotosScreen(profileCubit: this),
    VideosScreen(profileCubit: this),
  ];

  void setProfileCubit(ProfileCubit cubit) {
    emit(state.setSuccess());
  }

  void setUserId(String uId) {
    emit(state.setUserId(uId));
  }

  void _loadMorePosts() {
    if (state.hasMorePosts && state.isLoadingMore) {
      emit(state.setIsLoadingMore(false));
      getProfileData(userId: state.userId).whenComplete(
              () => emit(state.setIsLoadingMore(true))
      );
    }
  }

  void _loadMoreProfileImages() {
    if (state.hasMoreProfileImages && state.isLoadingMore) {
      emit(state.setIsLoadingMore(false));
      getProfileImages(userId: state.userId).whenComplete(
              () => emit(state.setIsLoadingMore(true))
      );
    }
  }

  void _loadMoreCoverImages() {
    if (state.hasMoreCoverImages && state.isLoadingMore) {
      emit(state.setIsLoadingMore(false));
      getCoverImages(userId: state.userId).whenComplete(
              () => emit(state.setIsLoadingMore(true))
      );
    }
  }

  void changeIndex(int index) {
    emit(state.setCurrentIndex(index));
  }

  void changeIndexButtons(index, userId) {
    emit(state.setCurrentButton(index, userId));
  }

  void addPost(PostModel postModel) {
    emit(state.addPost(postModel));
  }

  Future<void> insertFriendsRequests({
    required final String userId,
  }) async {
    emit(state.setLoading());
    try {
      final UserModel friendsInfo = UserModel(
          userId: UserDetails.uId,
          dateTime: DateTime.now()
      );
      await _useCases.executeSendFriendRequest(userId, friendsInfo);
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
    }
  }

  Future<void> deleteRequests({
    required String userId
  }) async {
    emit(state.setLoading());
    try {
      await _useCases.executeDeleteFriendRequest(userId);
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
    }
  }

  Future<void> deleteFriendship({
    required String userId
  }) async {
    emit(state.setLoading());
    try {
      await _useCases.executeDeleteFriendship(userId);
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
    }
  }

  Future<void> getProfileInfo({
    required String uid
  }) async {
    emit(state.setLoading());
    try {
      final profileInfo = await _useCases.executeGetProfileInfo(uid);
      if (profileInfo != null) {
        emit(state.updateProfileInfo(profileInfo));
      }
      emit(state.setUserId(uid));
      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> getInfo({
    required String uid
  }) async {
    emit(state.setLoading());
    try {
      final profileInfo = await _useCases.executeGetInfo(uid);
      if (profileInfo != null) {
        emit(state.updateProfileInfo(profileInfo));
      }
      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> insertAndUpdatePosts({
    required PostModel postModel
  }) async {
    emit(state.setLoading());
    try {
      await _useCases.executeInsertPost(postModel);
      addPost(postModel);
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
    }
  }

  Future<void> uploadImage({
    required PostModel postModel,
  }) async {
    emit(state.setLoading());
    try {
      final userModel = await getUserAccountData();

      postModel
        ..userId = userModel.userId
        ..userName = userModel.userName
        ..userImage = userModel.userImage;

      if (postModel.postType == 'profileImage') {
        await _useCases.executeUploadImage(
          postModel: postModel,
          collection: 'accounts',
          imageType: 'userImage',
        );
        emit(state.addProfileImage(postModel));
        if (state.profileInfo != null) {
          final updatedInfo = state.profileInfo!.copyWith(profileImage: postModel);
          emit(state.updateProfileInfo(updatedInfo));
        }
        if (userModel.userImage != null) {
          UserDetails.image = userModel.userImage!;
        }
      } else {
        await _useCases.executeUploadImage(
          postModel: postModel,
          collection: 'info',
          imageType: 'userCover',
        );
        emit(state.addCoverImage(postModel));
        if (state.profileInfo != null) {
          final updatedInfo = state.profileInfo!.copyWith(coverImage: postModel);
          emit(state.updateProfileInfo(updatedInfo));
        }
      }
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
    }
  }

  Future<void> getProfileData({
    required final String userId
  }) async {
    emit(state.setLoading());

    try {
      final result = await _useCases.executeGetProfileData(userId, state.lastPostDoc);

      if (result.posts.isEmpty) {
        emit(state.setHasMorePosts(false));
        emit(state.setSuccess());
        return;
      }

      emit(state.updatePostsDataList(result.posts, append: true));
      emit(state.updateLastPostDoc(result.lastDoc));
      emit(state.setHasMorePosts(result.hasMore));

      // تحديث الألبوم
      if (state.postsDataList.isNotEmpty) {
        emit(state.updateAlbumImage(0, state.postsDataList.last));
        emit(state.updateAlbumScreenList(0, state.postsDataList));
      }

      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> getProfileImages({
    required String userId
  }) async {
    emit(state.setLoadingWithKey(StatesKeys.getProfileImages));

    try {
      final result = await _useCases.executeGetProfileImages(userId, state.lastProfileImageDoc);

      if (result.images.isEmpty) {
        emit(state.setHasMoreProfileImages(false));
        emit(state.setSuccess());
        return;
      }

      emit(state.updateProfileImagesList(result.images, append: true));
      emit(state.updateLastProfileImageDoc(result.lastDoc));
      emit(state.setHasMoreProfileImages(result.hasMore));

      // تحديث الألبوم
      if (state.profileImagesList.isNotEmpty) {
        emit(state.updateAlbumImage(1, state.profileImagesList.last));
        emit(state.updateAlbumScreenList(1, state.profileImagesList));
      }

      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> getCoverImages({
    required String userId,
  }) async {
    emit(state.setLoadingWithKey(StatesKeys.getCoverImages));

    try {
      final result = await _useCases.executeGetCoverImages(userId, state.lastCoverImageDoc);

      if (result.covers.isEmpty) {
        emit(state.setHasMoreCoverImages(false));
        emit(state.setSuccess());
        return;
      }

      emit(state.updateCoverImagesList(result.covers, append: true));
      emit(state.updateLastCoverImageDoc(result.lastDoc));
      emit(state.setHasMoreCoverImages(result.hasMore));

      // تحديث الألبوم
      if (state.coverImagesList.isNotEmpty) {
        emit(state.updateAlbumImage(2, state.coverImagesList.last));
        emit(state.updateAlbumScreenList(2, state.coverImagesList));
      }

      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> getVideosPosts({
    required String userId
  }) async {
    emit(state.setLoading());

    try {
      final result = await _useCases.executeGetVideosPosts(userId, state.lastProfileImageDoc);

      if (result.videos.isEmpty) {
        emit(state.setSuccess());
        return;
      }

      emit(state.updateVideosList(result.videos, append: true));
      emit(state.updateLastProfileImageDoc(result.lastDoc));

      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> addFriend({
    required final String userImage,
    required final String userName,
    required final String uId,
    required final String docId
  }) async {
    emit(state.setLoading());
    try {
      final UserModel friendsInfo = UserModel(
          userId: uId,
          userImage: userImage,
          userName: userName
      );
      await _useCases.executeAddFriend(docId, friendsInfo);
      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> getFriends({
    required String userId
  }) async {
    emit(state.setLoading());
    try {
      final friends = await _useCases.executeGetFriends(userId);
      emit(state.updateFriendsList(friends));
      emit(state.setSuccess());
    } catch (e) {
      emit(state.setError(e.toString()));
    }
  }

  Future<void> checkIsRequest({
    required String userId
  }) async {
    emit(state.setLoading());
    try {
      final exists = await _useCases.executeCheckIsRequest(userId);
      emit(state.setIsRequest(exists));
      emit(state.setSuccess());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> checkIsFriend({
    required final String userId
  }) async {
    emit(state.setLoading());
    try {
      final exists = await _useCases.executeCheckIsFriend(userId);
      emit(state.setIsFriend(exists));
      emit(state.setSuccess());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> deletePost({
    required PostModel postModel
  }) async {
    emit(state.removePost(postModel.docId!));
    await _useCases.executeDeletePost(postModel.docId!);
    emit(state.setSuccess());
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}