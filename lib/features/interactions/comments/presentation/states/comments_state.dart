import '../../../../../core/data/models/comment_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/errors/exceptions/base/app_exception.dart';
import '../../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/interactions/comments/data/models/comments_success_state.dart';


class CommentsState extends MainAppSupState {
  final MessageResult messageResult;
  final List<CommentModel> commentsList;

  CommentsState({
    required super.subState,
    required this.commentsList,
    required this.messageResult
  });

  factory CommentsState.initial(){
    return CommentsState(
        commentsList: [],
        subState: InitialState(),
        messageResult: MessageResult.initial()
    );
  }

  CommentsState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<CommentModel>? commentsList
  }) {
    return CommentsState(
        subState: subState ?? this.subState,
        commentsList: commentsList ?? this.commentsList,
        messageResult: messageResult ?? this.messageResult
    );
  }

  CommentsState setInitialState() => copyWith(subState: InitialState());

  CommentsState setErrorMessage(AppException failure) =>
      copyWith(messageResult: MessageResult.error(failure: failure));

  @override
  CommentsSuccessState get dataModels =>
      CommentsSuccessState(
          commentsList: commentsList,
          messageResult: messageResult
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(CommentsSuccessState) onLoaded,
    required R Function(AppException) onError}) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded(dataModels),
        onError: (failure) => onError(failure)
    );
  }
}