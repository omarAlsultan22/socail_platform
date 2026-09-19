import 'dart:async';
import '../../states/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/useCases/profile_useCase.dart';
import '../../../../../core/data/models/post_model.dart';
import '../../../../../core/data/models/user_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../../core/services/user_account_service.dart';
import '../../../../../core/presentation/mixins/error_handler_mixin.dart';


abstract class MainProfileCubit extends Cubit<ProfileState> with ErrorHandlerMixin<ProfileState>{
  final ProfileUseCase _useCases;
  final SessionService _sessionService;
  final UserAccountService _userAccountService;

  MainProfileCubit({
    required ProfileUseCase useCase,
    required SessionService sessionService,
    required UserAccountService userAccountService
  })
      : _useCases = useCase,
        _sessionService = sessionService,
        _userAccountService = userAccountService,
        super(ProfileState.initial()) {
    emit(state.copyWith(
      listenerScreens: [
        _loadMorePosts,
        _loadMoreProfileImages,
        _loadMoreCoverImages,
      ],
    ));
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

  void changeIndexButtons(int index, String userId) {
    emit(state.setCurrentButton(index, userId));
  }

  void addPost(PostModel postModel) {
    emit(state.addPost(postModel));
  }

  Future<void> insertFriendsRequests({
    required final String userId,
  }) async {
    emit(state.setLoadingState());
    try {
      final UserModel friendsInfo = UserModel(
          dateTime: DateTime.now(),
          userId: _sessionService.currentUid
      );
      await _useCases.executeSendFriendRequest(userId, friendsInfo);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> deleteRequests({
    required String userId
  }) async {
    emit(state.setLoadingState());
    try {
      await _useCases.executeDeleteFriendRequest(userId);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> deleteFriendship({
    required String userId
  }) async {
    emit(state.setLoadingState());
    try {
      await _useCases.executeDeleteFriendship(userId);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getProfileInfo({
    required String uid
  }) async {
    emit(state.setLoadingState());
    try {
      final profileInfo = await _useCases.executeGetProfileInfo(uid);
      if (profileInfo != null) {
        emit(state.copyWith(profileInfo: profileInfo));
      }
      emit(state.setUserId(uid));
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getInfo({
    required String uid
  }) async {
    emit(state.setLoadingState());
    try {
      final profileInfo = await _useCases.executeGetInfo(uid);
      if (profileInfo != null) {
        emit(state.copyWith(profileInfo: profileInfo));
      }
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> insertAndUpdatePosts({
    required PostModel postModel
  }) async {
    emit(state.setLoadingState());
    try {
      await _useCases.executeInsertPost(postModel);
      addPost(postModel);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> uploadImage({
    required PostModel postModel,
  }) async {
    emit(state.setLoadingState());
    try {
      final userModel = await _userAccountService.getUserAccountData();

      postModel.copyWith(
          userId: userModel.userId,
          userName: userModel.userName,
          userImage: userModel.userImage
      );

      if (postModel.postType == 'profileImage') {
        await _useCases.executeUploadImage(
          postModel: postModel,
          collection: 'accounts',
          imageType: 'userImage',
        );
        emit(state.addProfileImage(postModel));
        if (state.profileInfoModel != null) {
          final profileInfo = state.updateProfileInfo(profileImage: postModel);
          emit(state.copyWith(profileInfo: profileInfo));
        }
      } else {
        await _useCases.executeUploadImage(
          postModel: postModel,
          collection: 'info',
          imageType: 'userCover',
        );
        emit(state.addCoverImage(postModel));
        if (state.profileInfoModel != null) {
          final profileInfo = state.profileInfoModel!.copyWith(
              coverImage: postModel);
          emit(state.copyWith(profileInfo: profileInfo));
        }
      }
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getProfileData({
    required String userId
  }) async {
    emit(state.setLoadingState());

    try {
      final paginatedPosts = await _useCases.executeGetProfileData(
          userId, state.lastPostDoc);

      if (paginatedPosts.postsList.isEmpty) {
        emit(state.setHasMorePosts(false));
        emit(state.setSuccessState());
        return;
      }

      emit(state.updatePostsDataList(paginatedPosts.postsList, append: true));
      emit(state.updateLastPostDoc(paginatedPosts.lastPostDoc));
      emit(state.setHasMorePosts(paginatedPosts.hasMorePosts));

      // تحديث الألبوم
      if (state.postsDataList.isNotEmpty) {
        emit(state.updateAlbumImage(0, state.postsDataList.last));
        emit(state.updateAlbumScreenList(0, state.postsDataList));
      }

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getProfileImages({
    required String userId
  }) async {
    emit(state.setLoadingState());

    try {
      final paginatedPosts = await _useCases.executeGetProfileImages(
          userId, state.lastProfileImageDoc);

      if (paginatedPosts.postsList.isEmpty) {
        emit(state.setHasMoreProfileImages(false));
        emit(state.setSuccessState());
        return;
      }

      emit(state.updateProfileImagesList(
          paginatedPosts.postsList, append: true));
      emit(state.updateLastProfileImageDoc(paginatedPosts.lastPostDoc));
      emit(state.setHasMoreProfileImages(paginatedPosts.hasMorePosts));

      // تحديث الألبوم
      if (state.profileImagesList.isNotEmpty) {
        emit(state.updateAlbumImage(1, state.profileImagesList.last));
        emit(state.updateAlbumScreenList(1, state.profileImagesList));
      }

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getCoverImages({
    required String userId,
  }) async {
    emit(state.setLoadingState());

    try {
      final paginatedPosts = await _useCases.executeGetCoverImages(
          userId, state.lastCoverImageDoc);

      if (paginatedPosts.postsList.isEmpty) {
        emit(state.setHasMoreCoverImages(false));
        emit(state.setSuccessState());
        return;
      }

      emit(state.updateCoverImagesList(paginatedPosts.postsList, append: true));
      emit(state.updateLastCoverImageDoc(paginatedPosts.lastPostDoc));
      emit(state.setHasMoreCoverImages(paginatedPosts.hasMorePosts));

      // تحديث الألبوم
      if (state.coverImagesList.isNotEmpty) {
        emit(state.updateAlbumImage(2, state.coverImagesList.last));
        emit(state.updateAlbumScreenList(2, state.coverImagesList));
      }

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getVideosPosts({
    required String userId
  }) async {
    emit(state.setLoadingState());

    try {
      final paginatedPosts = await _useCases.executeGetVideosPosts(userId, state.lastProfileImageDoc);

      if (paginatedPosts.postsList.isEmpty) {
        emit(state.setSuccessState());
        return;
      }

      emit(state.updateVideosList(paginatedPosts.postsList, append: true));
      emit(state.updateLastVideoDoc(paginatedPosts.lastPostDoc));
      emit(state.setHasMoreVideos(paginatedPosts.hasMorePosts));


      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> addFriend({
    required final String userImage,
    required final String userName,
    required final String uId,
    required final String docId
  }) async {
    emit(state.setLoadingState());
    try {
      final UserModel friendsInfo = UserModel(
          userId: uId,
        userName: userName,
        userImage: userImage
      );
      await _useCases.executeAddFriend(docId, friendsInfo);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getFriends({
    required String userId
  }) async {
    emit(state.setLoadingState());
    try {
      final friends = await _useCases.executeGetFriends(userId);
      emit(state.updateFriendsList(friends));
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> checkIsRequest({
    required String userId
  }) async {
    if(_sessionService.currentUid != userId) {
      final exists = await _useCases.executeCheckIsRequest(userId);
      emit(state.setIsRequest(exists));
    }
  }

  Future<void> checkIsFriend({
    required String userId
  }) async {
    if(_sessionService.currentUid != userId) {
      final exists = await _useCases.executeCheckIsFriend(userId);
      emit(state.setIsFriend(exists));
    }
  }

  Future<void> deletePost({
    required PostModel postModel
  }) async {
    emit(state.removePost(postModel.docId!));
    await _useCases.executeDeletePost(postModel.docId!);
    emit(state.setSuccessState());
  }
}