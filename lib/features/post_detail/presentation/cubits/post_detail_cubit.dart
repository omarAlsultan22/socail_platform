import 'dart:async';
import '../states/post_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/post_model.dart';
import '../../domain/use_cases/post_detail_use_case.dart';
import '../../../../core/domain/use_cases/like_use_case.dart';
import '../../../../core/domain/use_cases/post_use_case.dart';
import '../../../../core/domain/use_cases/share_use_case.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';
import 'package:social_app/core/presentation/mixins/post_operations_mixin.dart';


class PostDetailCubit extends Cubit<PostDetailState> with PostOperationsMixin, ErrorHandlerMixin<PostDetailState> {
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final PostDetailUseCase _useCases;
  final IUserAccountService _userAccountService;

  StreamSubscription? _notificationsSubscription;

  PostDetailCubit({
    required PostUseCase postUseCase,
    required LikeUseCase likeUseCase,
    required ShareUseCase shareUseCase,
    required PostDetailUseCase useCase,
    required IUserAccountService userAccountService
  })
      : _useCases = useCase,
        _postUseCase = postUseCase,
        _likeUseCase = likeUseCase,
        _shareUseCase = shareUseCase,
        _userAccountService = userAccountService,
        super(PostDetailState.initial());

  static PostDetailCubit get(context) => BlocProvider.of(context);

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

  Future<void> insertNotifications({
    required final String userUid,
    required final String userImage,
    required final String userName,
    required final String userAction,
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      await _useCases.executeInsertNotification(
        userUid: userUid,
        userImage: userImage,
        fullName: userName,
        userAction: userAction,
      );

      emit(state.copyWith(messageResult: MessageResult.success()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(failure: failure)
              )
      );
    }
  }

  Future<void> getPostData({
    required String userId,
    required String postId,
  }) async {
    emit(state.copyWith(subState: LoadingState()));

    if (userId.isEmpty || postId.isEmpty) {
      throw ValidationException(
        error: 'userId and postId must not be empty',
      );
    }
    try {
      final postDetailModel = await _useCases.executeGetPostData(
        userId: userId,
        postId: postId,
      );

      if (postDetailModel.postModel != null &&
          postDetailModel.commentsList != null) {
        emit(
            state.copyWith(
                postModel: postDetailModel.postModel,
                commentsList: postDetailModel.commentsList,
                subState: SuccessState()
            )
        );
        return;
      }
      emit(state.copyWith(subState: InitialState()));
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
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}