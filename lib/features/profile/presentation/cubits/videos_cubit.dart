import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/domain/use_cases/like_use_case.dart';
import '../../../../core/domain/use_cases/post_use_case.dart';
import '../../../../core/domain/use_cases/share_use_case.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/presentation/coordinators/post_syncable.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/presentation/mixins/post_operations_mixin.dart';
import 'package:social_app/features/profile/domain/use_cases/videos_use_case.dart';
import 'package:social_app/features/profile/presentation/states/videos_state.dart';


class VideosCubit extends Cubit<VideosState> with PostOperationsMixin, ErrorHandlerMixin<VideosState> implements PostSyncable {
  final VideosUseCase _useCases;
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final IUserAccountService _userAccountService;

  VideosCubit({
    required VideosUseCase useCase,
    required PostUseCase postUseCase,
    required LikeUseCase likeUseCase,
    required ShareUseCase shareUseCase,
    required IUserAccountService userAccountService
  })
      : _useCases = useCase,
        _postUseCase = postUseCase,
        _likeUseCase = likeUseCase,
        _shareUseCase = shareUseCase,
        _userAccountService = userAccountService,
        super(VideosState.initial());

  static VideosCubit get(context) => BlocProvider.of(context);

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

  @override
  void upsertPostToList(PostModel postModel) {
    emit(state.upsertPost(postModel));
  }

  @override
  void removePostFromList(PostModel postModel) {
    emit(state.removePost(postModel));
  }

  Future<void> getVideosPosts({
    required String userId
  }) async {
    emit(state.copyWith(subState: InitialState()));

    try {
      final paginatedData = await _useCases.executeGetVideosPosts(
          userId, state.lastVideoDoc);

      if (paginatedData.dataListIsEmpty && state.videosListIsEmpty) {
        emit(
            state.copyWith(
                subState: InitialState(),
                lastVideoDoc: paginatedData.lastPostDoc,
                hasMoreVideos: paginatedData.hasMoreData
            )
        );
        return;
      }

      emit(state.updateVideosList(paginatedData.dataList, append: true));
      emit(state.updateLastVideoDoc(paginatedData.lastPostDoc));
      emit(state.setHasMoreVideos(paginatedData.hasMoreData));

      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(subState: ErrorState(failure: failure))
      );
    }
  }

  void loadMoreVideos(String userId) {
    if (state.hasMoreVideos) {
      try {
        getVideosPosts(userId: userId);
      }
      catch (e, stackTrace) {
        handleError(e, stackTrace,
            onError: (failure) =>
                state.copyWith(
                    messageResult: MessageResult.error(failure: failure)
                )
        );
      }
    }
  }
}