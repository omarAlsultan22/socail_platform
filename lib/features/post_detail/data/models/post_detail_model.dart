import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';


class PostDetailModel {
  final PostModel? postModel;
  final List<CommentModel>? commentsList;

  const PostDetailModel({this.postModel, this.commentsList});

  int get commentsListLength => commentsList!.length;

  String? getUserId(int index) => getCommentModel(index).userId;

  CommentModel getCommentModel(int index) => commentsList![index];
}