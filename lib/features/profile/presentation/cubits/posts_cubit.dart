import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/posts_use_case.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/domain/use_cases/like_use_case.dart';
import '../../../../core/domain/use_cases/share_use_case.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/mixins/post_operations_mixin.dart';
import 'package:social_app/core/presentation/coordinators/post_syncable.dart';
import 'package:social_app/features/profile/presentation/states/posts_state.dart';


class PostsCubit extends Cubit<PostsState> with PostOperationsMixin, ErrorHandlerMixin<PostsState> implements PostSyncable{
  final PostsUseCase _useCases;
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final IUserAccountService _userAccountService;

  PostsCubit({
    required PostsUseCase useCase,
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
        super(PostsState.initial());

  static PostsCubit get(context) => BlocProvider.of(context);

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
              state.copyWith(messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  @override
  Future<void> removePostFromRepository({required PostModel postModel}) async{
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
              state.copyWith(messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  @override
  void upsertPostToList(PostModel postModel) {
    emit(state.upsertPost(postModel));
  }

  @override
  void removePostFromList(PostModel postModel){
    emit(state.removePost(postModel.myDocId));
  }

  Future<void> getPostsData({
    required String userId
  }) async {
    emit(state.setLoadingState());

    try {
      final paginatedPosts = await _useCases.executeGetPostsData(
          userId, state.lastPostDoc);

      if (paginatedPosts.dataListIsEmpty && state.postDataIsEmpty) {
        emit(state.setHasMorePosts(false));
        emit(state.copyWith(subState: InitialState()));
        return;
      }

      emit(state.updatePostsDataList(paginatedPosts.dataList, append: true));
      emit(state.updateLastPostDoc(paginatedPosts.lastPostDoc));
      emit(state.setHasMorePosts(paginatedPosts.hasMoreData));

      emit(state.setSuccessState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }

  Future<void> loadMorePosts(String userId) async {
    if (state.hasMorePosts) {
      try {
        await getPostsData(userId: userId).whenComplete(() =>
            emit(state.setSuccessState()
            )
        );
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
}