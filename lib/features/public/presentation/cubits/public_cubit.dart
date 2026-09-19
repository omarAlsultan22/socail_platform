import 'dart:async';
import '../states/public_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/public_use_cases.dart';
import '../../../../core/data/models/post_model.dart';
import '../../data/services/online_status_service.dart';
import '../../../../core/services/user_account_service.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/user_details.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class PublicCubit extends Cubit<PublicState> with ErrorHandlerMixin<PublicState> {
  final PublicUseCase _useCases;
  final SessionService _sessionService;
  final UserAccountService _userAccountService;
  StreamSubscription? _onlineSubscription;

  PublicCubit({
    required PublicUseCase useCase,
    required SessionService sessionService,
    required UserAccountService userAccountService
  })
      : _useCases = useCase,
        _sessionService = sessionService,
        _userAccountService = userAccountService,
        super(PublicState.initial());

  static PublicCubit get(context) => BlocProvider.of(context);

  bool get hasMorePosts => state.hasMorePosts;

  void getUserOnlineStatus(OnlineStatusService onlineStatusService,
      String userId) {
    _onlineSubscription = _useCases.executeGetUserOnlineStatus(
      onlineStatusService,
      userId,
    ).listen((value) {
      emit(state.setOnlineStatus(value));
    });
  }

  void addPost(PostModel postModel) {
    emit(state.addPostAtBeginning(postModel));
  }

  void addStatus(PostModel statusModel) {
    final currentMyStatuses = state.myStatuses;
    List<PostModel> newMyStatuses;

    if (state.homeStatusesList.isNotEmpty &&
        state.homeStatusesList.first.first.userId ==
            _sessionService.currentUid) {
      newMyStatuses = [statusModel, ...currentMyStatuses];
    } else {
      newMyStatuses = [statusModel];
    }

    emit(
        state.addStatus(
            status: statusModel,
            myStatusesList: newMyStatuses,
            currentUId: _sessionService.currentUid
        )
    );
  }

  Future<void> insertAndUpdateStatuses({
    required PostModel statusModel
  }) async {
    emit(state.setLoadingState());
    try {
      if (statusModel.userId == null) {
        final userModel = await _userAccountService.getUserAccountData();
        final newStatusModel = statusModel.copyWith(
          userId:  userModel.userId,
          userName:  userModel.userName,
          userImage: userModel.userImage
        );

        addStatus(newStatusModel);
        await _useCases.executeInsertStatus(newStatusModel);
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
      if (postModel.userId == null) {
        final userModel = await _userAccountService.getUserAccountData();
        postModel = postModel.copyWith(
            userId:  userModel.userId,
            userName:  userModel.userName,
            userImage: userModel.userImage,
            postType: postModel.postType ?? 'post'
        );
      }
      addPost(postModel);
      await _useCases.executeInsertPost(postModel);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getUserAccount() async {
    final userModel = await _useCases.executeGetUserAccount();
    final userDetails = UserDetails(
        userName: userModel.userName,
        userImage: userModel.userImage
    );
    emit(
        state.copyWith(userDetails: userDetails)
    );
  }

  Future<void> getHomePosts() async {
    if (!state.hasMorePosts) return;

    emit(state.setLoadingState());

    try {
      final result = await _useCases.executeGetHomePosts(
        lastPostDoc: state.lastPostDoc,
        hasMorePosts: state.hasMorePosts,
      );

      emit(state.updatePostsPagination(
        newPosts: result.postsList,
        hasMore: result.hasMorePosts,
        lastDoc: result.lastPostDoc,
      ));

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> getHomeStatus() async {
    if (!state.hasMoreStatuses) return;

    emit(state.setLoadingState());

    try {
      final result = await _useCases.executeGetHomeStatus(
        lastStatusDoc: state.lastStatusDoc,
        hasMoreStatuses: state.hasMoreStatuses,
      );

      emit(state.updateStatusesPagination(
        newStatuses: result.homeStatusesList,
        myStatusesList: result.myStatuses,
        hasMore: result.hasMoreStatuses,
        lastDoc: result.lastStatusDoc,
      ));

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> deletePost({
    required PostModel postModel
  }) async {
    final isMyPost = postModel.userId == _sessionService.currentUid;

    emit(state.removePost(postModel.docId!));

    await _useCases.executeDeletePost(
      postModel: postModel,
      isMyPost: isMyPost,
    );
    emit(state.setSuccessState());
  }

  Future<void> deleteStatus({
    required PostModel statusModel,
  }) async {
    try {
      final isMyStatus = statusModel.userId == _sessionService.currentUid;

      emit(state.removeStatus(statusModel.docId!));

      await _useCases.executeDeleteStatus(
        statusModel: statusModel,
        isMyStatus: isMyStatus,
      );

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  @override
  Future<void> close() async {
    await _onlineSubscription?.cancel();
    return super.close();
  }
}