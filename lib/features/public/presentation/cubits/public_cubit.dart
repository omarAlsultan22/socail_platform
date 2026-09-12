import 'dart:async';
import '../states/public_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/public_use_cases.dart';
import '../../../../core/data/models/post_model.dart';
import '../../data/services/online_status_service.dart';
import '../../../../core/services/user_account_service.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


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

  void changeIsLoadingPosts(bool value) {
    emit(state.setLoadingPosts(value));
  }

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
    emit(state.copyWith(subState: LoadingState()));
    try {
      if (statusModel.userId == null) {
        final userModel = await _userAccountService.getUserAccountData();
        statusModel
          ..userId = userModel.userId
          ..userName = userModel.userName
          ..userImage = userModel.userImage;

        addStatus(statusModel);
        await _useCases.executeInsertStatus(statusModel);
      }
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> insertAndUpdatePosts({
    required PostModel postModel
  }) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      if (postModel.userId == null) {
        final userModel = await _userAccountService.getUserAccountData();
        postModel
          ..userId = userModel.userId
          ..userName = userModel.userName
          ..userImage = userModel.userImage
          ..postType = postModel.postType ?? 'post';
      }
      addPost(postModel);
      await _useCases.executeInsertPost(postModel);
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> getUserAccount() async {
    await _useCases.executeGetUserAccount();
  }

  Future<void> getHomePosts() async {
    if (!state.hasMorePosts) return;

    emit(state.setLoadingPosts(true));

    try {
      final result = await _useCases.executeGetHomePosts(
        lastPostDoc: state.lastPostDoc,
        hasMorePosts: state.hasMorePosts,
      );

      emit(state.updatePostsPagination(
        newPosts: result.homePostsList,
        hasMore: result.hasMorePosts,
        lastDoc: result.lastPostDoc,
      ));

      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    } finally {
      emit(state.setLoadingPosts(false));
    }
  }

  Future<void> getHomeStatus() async {
    if (!state.hasMoreStatuses) return;

    emit(state.copyWith(subState: LoadingState()));

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

      emit(state.copyWith(subState: SuccessState()));
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
    final isMyPost = postModel.userId == _sessionService.currentUid;

    emit(state.removePost(postModel.docId!));

    await _useCases.executeDeletePost(
      postModel: postModel,
      isMyPost: isMyPost,
    );
    emit(state.copyWith(subState: SuccessState()));
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

      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  @override
  Future<void> close() async {
    await _onlineSubscription?.cancel();
    return super.close();
  }
}