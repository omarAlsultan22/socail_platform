import 'dart:async';
import 'package:social_app/features/public/data/models/user_details.dart';

import '../states/public_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/public_use_case.dart';
import '../../../../core/data/models/post_model.dart';
import '../../data/services/online_status_service.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/services/user_account_service.dart';
import '../../../../core/domain/use_cases/post_use_case.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/domain/use_cases/like_use_case.dart';
import 'package:social_app/core/domain/use_cases/share_use_case.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/presentation/coordinators/post_syncable.dart';
import '../../../../core/presentation/mixins/post_operations_mixin.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';


class PublicCubit extends Cubit<PublicState> with PostOperationsMixin, ErrorHandlerMixin<PublicState> implements PostSyncable {
  final PublicUseCase _useCases;
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final SessionService _sessionService;
  StreamSubscription? _onlineSubscription;
  final UserAccountService _userAccountService;
  final UserDetailsUseCase _userDetailsUseCase;

  PublicCubit({
    required PublicUseCase useCase,
    required PostUseCase postUseCase,
    required LikeUseCase likeUseCase,
    required ShareUseCase shareUseCase,
    required SessionService sessionService,
    required UserDetailsUseCase userDetailsUseCase,
    required UserAccountService userAccountService
  })
      : _useCases = useCase,
        _postUseCase = postUseCase,
        _likeUseCase = likeUseCase,
        _shareUseCase = shareUseCase,
        _sessionService = sessionService,
        _userDetailsUseCase = userDetailsUseCase,
        _userAccountService = userAccountService,
        super(PublicState.initial()) {
    emit(state.copyWith(currentUid: sessionService.currentUid));
  }

  static PublicCubit get(context) => BlocProvider.of(context);

  bool get hasMorePosts => state.hasMorePosts;

  @override
  PostUseCase get postUseCase => _postUseCase;

  @override
  LikeUseCase get likeUseCase => _likeUseCase;

  @override
  ShareUseCase get shareUseCase => _shareUseCase;

  @override
  UserDetailsUseCase get userDetailsUseCase => _userDetailsUseCase;

  @override
  UserAccountService get userAccountService => _userAccountService;

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

  @override
  void upsertPostToList(PostModel postModel) {
    emit(state.upsertPost(postModel));
  }

  @override
  void removePostFromList(PostModel postModel) {
    emit(state.removePost(postModel.myDocId));
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

  void updateUserDetails(UserDetails userDetails) {
    emit(state.updateUserDetailsMap(userDetails));
  }

  void addStatus(PostModel statusModel) {
    final currentMyStatuses = state.myStatuses;
    List<PostModel> newMyStatuses;

    if (state.homeStatusesList.isNotEmpty &&
        state.homeStatusesList.first.first.myId ==
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

  Future<void> upsertStatus({
    required PostModel statusModel
  }) async {
    emit(state.setLoadingState());
    try {
      var newStatus = statusModel;
      if (newStatus.myId.isEmpty) {
        final userModel = await userAccountService.getUserAccountData();
        newStatus = statusModel.copyWith(
            myId: userModel.myId,
        );
      }
      addStatus(newStatus);
      await _useCases.executeInsertStatus(newStatus);
      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
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
        newPosts: result.dataList,
        hasMore: result.hasMoreData,
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

  Future<void> removeStatus({
    required PostModel statusModel,
  }) async {
    try {
      final isMyStatus = statusModel.myId == _sessionService.currentUid;

      emit(state.removeStatus(statusModel.myDocId));

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