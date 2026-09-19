import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class PostDetailSuccessState extends LoadedState {
  final PostModel postModel;
  final MessageResult messageResult;
  final List<CommentModel> commentsList;

  const PostDetailSuccessState({
    required this.postModel,
    required this.commentsList,
    required this.messageResult
  });

  int get commentsListLength => commentsList.length;

  String? getUserId(int index) => getCommentModel(index).userId;

  CommentModel getCommentModel(int index) => commentsList[index];
}