import 'dart:async';
import '../states/comments_likes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/data/models/comment_model.dart';
import '../../../../../core/presentation/states/app_sub_states.dart';
import '../../domain/use_cases/get_comment_likes_stream_use_case.dart';
import 'package:social_app/core/presentation/mixins/error_handler_mixin.dart';


class CommentsLikesCubit extends Cubit<CommentsLikesState> with ErrorHandlerMixin {
  final GetCommentLikesStreamUseCase getCommentLikesStreamUseCase;

  CommentsLikesCubit({
    required this.getCommentLikesStreamUseCase,
  }) : super(CommentsLikesState.initial());

  static CommentsLikesCubit get(context) =>
      BlocProvider.of(context);

  StreamSubscription? _likesSubscription;

  // ============ STREAM ============
  void listenToLikes(CommentModel? comment) {
    _likesSubscription?.cancel();

    if (comment == null) {
      emit(state.copyWith(subState: InitialState()));
      return;
    }

    emit(state.copyWith(subState: LoadingState()));

    try {
      _likesSubscription = getCommentLikesStreamUseCase(
        postId: comment.postId,
        commentId: comment.docId,
      ).listen(
              (commentsLikesList) {
            emit(
                state.copyWith(
                    subState: SuccessState(),
                    commentsLikesList: commentsLikesList
                )
            );
          });
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.copyWith(
              subState: ErrorState(failure: failure)
          )
      );
    }
  }

  @override
  Future<void> close() async {
    await _likesSubscription?.cancel();
    return super.close();
  }
}