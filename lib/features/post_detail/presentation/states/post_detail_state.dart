import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';
import '../../../../core/data/models/message_result.dart';
import '../../data/models/post_detail_success_state.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class PostDetailState extends MainAppSupState {
  final PostModel postModel;
  final MessageResult messageResult;
  final List<CommentModel> commentsList;

  const PostDetailState({
    required super.subState,
    required this.postModel,
    required this.commentsList,
    required this.messageResult,
  });

  factory PostDetailState.initial() {
    return PostDetailState(
        postModel: PostModel(),
        commentsList: const [],
        subState: InitialState(),
        messageResult: MessageResult.initial()
    );
  }

  PostDetailState copyWith({
    PostModel? postModel,
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<CommentModel>? commentsList,
  }) {
    return PostDetailState(
      subState: subState ?? this.subState,
      postModel: postModel ?? this.postModel,
      commentsList: commentsList ?? this.commentsList,
      messageResult: messageResult ?? this.messageResult,
    );
  }

  @override
  PostDetailSuccessState get dataModels =>
      PostDetailSuccessState(
          postModel: postModel,
          commentsList: commentsList,
          messageResult: messageResult
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(PostDetailSuccessState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}