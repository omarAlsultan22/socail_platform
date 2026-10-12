import 'dart:async';
import '../states/comments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/add_comment_use_case.dart';
import '../../domain/use_cases/remove_comment_use_case.dart';
import '../../domain/use_cases/add_comment_like_use_case.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../domain/use_cases/delete_comment_like_use_case.dart';
import '../../domain/use_cases/get_comments_stream_use_case.dart';
import '../../../../../core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/presentation/mixins/error_handler_mixin.dart';


class CommentsCubit extends Cubit<CommentsState>
    with ErrorHandlerMixin<CommentsState> {
  final AddCommentUseCase addCommentUseCase;
  final RemoveCommentUseCase removeCommentUseCase;
  final AddCommentLikeUseCase addCommentLikeUseCase;
  final DeleteCommentLikeUseCase deleteCommentLikeUseCase;
  final GetCommentsStreamUseCase getCommentsStreamUseCase;

  CommentsCubit({
    required this.addCommentUseCase,
    required this.removeCommentUseCase,
    required this.addCommentLikeUseCase,
    required this.deleteCommentLikeUseCase,
    required this.getCommentsStreamUseCase,
  }) : super(CommentsState.initial());

  static CommentsCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _commentsSubscription;

  // ============ STREAM ============
  void listenToComments(String? docId) {
    _commentsSubscription?.cancel();

    if (docId == null || docId.isEmpty) {
      emit(state.setInitialState());
      return;
    }

    emit(state.copyWith(subState: LoadingState()));

    try {
      _commentsSubscription = getCommentsStreamUseCase(docId).listen(
              (comments) {
            if (comments.isEmpty) {
              emit(state.setInitialState());
              return;
            }
            emit(state.copyWith(commentsList: comments));
          });
    }
    catch (e, stackTrace) {
      handleError(
          e,
          stackTrace,
          onError: (failure) =>
              state.copyWith(subState: ErrorState(failure: failure)));
    }
  }

  // ============ ACTIONS ============
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      await addCommentUseCase(postId: postId, comment: comment);
    } catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.setErrorMessage(failure)
      );
    }
  }

  Future<void> removeComment({required CommentModel comment}) async {
    try {
      await removeCommentUseCase(
        postId: comment.postId,
        commentId: comment.docId,
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.setErrorMessage(failure)
      );
    }
  }

  Future<void> addLike({required CommentModel comment}) async {
    try {
      await addCommentLikeUseCase(
        postId: comment.postId,
        commentId: comment.docId,
        commentOwnerId: comment.myId,
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.setErrorMessage(failure)
      );
    }
  }

  Future<void> removeLike({required CommentModel comment}) async {
    try {
      await deleteCommentLikeUseCase(
        postId: comment.postId,
        commentId: comment.docId,
        commentOwnerId: comment.myId,
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.setErrorMessage(failure)
      );
    }
  }

  void chickLike({
    required bool isLike,
    required CommentModel comment,
  }) {
    if (isLike) {
      addLike(comment: comment);
    } else {
      removeLike(comment: comment);
    }
  }

  @override
  Future<void> close() async {
    await _commentsSubscription?.cancel();
    return super.close();
  }
}