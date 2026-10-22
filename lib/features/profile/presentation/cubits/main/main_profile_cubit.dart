import 'dart:async';
import '../../states/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/data/models/my_model.dart';
import '../../../domain/use_cases/profile_use_case.dart';
import '../../../../../core/data/models/post_model.dart';
import '../../../../../core/data/models/message_result.dart';
import '../../../../../core/data/models/user_info_model.dart';
import '../../../../../core/domain/use_cases/like_use_case.dart';
import '../../../../../core/domain/use_cases/post_use_case.dart';
import '../../../../../core/domain/use_cases/share_use_case.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/services/domain/i_user_account_service.dart';
import '../../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../../core/presentation/mixins/post_operations_mixin.dart';


abstract class MainProfileCubit extends Cubit<ProfileState> with PostOperationsMixin, ErrorHandlerMixin<ProfileState> {
  final ProfileUseCase _useCases;
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  MainProfileCubit({
    required ProfileUseCase useCase,
    required PostUseCase postUseCase,
    required LikeUseCase likeUseCase,
    required ShareUseCase shareUseCase,
    required SessionService sessionService,
    required IUserAccountService userAccountService
  })
      : _useCases = useCase,
        _postUseCase = postUseCase,
        _likeUseCase = likeUseCase,
        _shareUseCase = shareUseCase,
        _sessionService = sessionService,
        _userAccountService = userAccountService,
        super(ProfileState.initial());

  @override
  PostUseCase get postUseCase => _postUseCase;

  @override
  LikeUseCase get likeUseCase => _likeUseCase;

  @override
  ShareUseCase get shareUseCase => _shareUseCase;

  @override
  IUserAccountService get userAccountService => _userAccountService;

  @override
  Future<void> upsertPostToRepository({required PostModel postModel}) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));
    try {
      await super.upsertPostToRepository(postModel: postModel)
          .whenComplete(() =>
          emit(state.copyWith(messageResult: MessageResult.success())
          )
      );
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  @override
  Future<void> removePostFromRepository({required PostModel postModel}) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));
    try {
      await super.removePostFromRepository(postModel: postModel)
          .whenComplete(() =>
          emit(state.copyWith(messageResult: MessageResult.success())
          )
      );
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  void changeIndexButtons(int index) {
    emit(state.setCurrentButton(index));
  }

  Future<void> insertFriendsRequests({
    required final String userId,
  }) async {
    emit(state.setLoadingState());
    try {
      final MyModel friendsInfo = MyModel(
          myDateTime: DateTime.now(),
          myId: _sessionService.currentUid
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

  Future<void> cancelRequests({
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

  Future<void> getProfileInfo({required String uId}) async {
    emit(state.setLoadingState());
    try {
      final profileInfo = await _useCases.executeGetProfileInfo(uId);
      if (profileInfo != null) {
        emit(state.copyWith(userInfoModel: profileInfo));
      }
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  void _setState(UserInfoModel userInfoModel) {
    emit(state.copyWith(userInfoModel: userInfoModel));
  }

  Future<void> _specifyImageType(PostModel postModel) async {
    if (postModel.postType == 'profileImage') {
      await _useCases.executeUploadImage(
        postModel: postModel,
        collection: 'accounts',
        imageType: 'userImage',
      );
      final userInfoModel = state.updateProfileInfo(profileImage: postModel);
      _setState(userInfoModel);
    } else {
      await _useCases.executeUploadImage(
        postModel: postModel,
        collection: 'info',
        imageType: 'userCover',
      );
      final userInfoModel = state.updateProfileInfo(
          coverImage: postModel);
      _setState(userInfoModel);
    }
  }

  Future<void> uploadImage({
    required PostModel postModel,
  }) async {
    emit(state.setLoadingState());
    try {
      final userModel = await _userAccountService.getUserAccountData();

      postModel = postModel.copyWith(
          myId: userModel.myId,
          userPost: userModel.myImageUrl
      );

      _specifyImageType(postModel);

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> addFriend({
    required final String uId,
    required final String docId,
    required final String imageUrl,
    required final String userName
  }) async {
    emit(state.setLoadingState());
    try {
      final MyModel friendsInfo = MyModel(
          myId: uId,
          myName: userName,
          myImageUrl: imageUrl
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

  Future<void> checkIsRequest({
    required String userId
  }) async {
    if (_sessionService.currentUid != userId) {
      final exists = await _useCases.executeCheckIsRequest(userId);
      if (exists) {
        emit(state.setIsRequest());
      }
    }
  }

  Future<void> checkIsFriend({
    required String userId
  }) async {
    if (_sessionService.currentUid != userId) {
      final exists = await _useCases.executeCheckIsFriend(userId);
      if (exists) {
        emit(state.setIsFriend());
      }
    }
  }
}