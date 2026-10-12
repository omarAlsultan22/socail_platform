import 'package:social_app/core/data/models/comment_model.dart';


abstract class CommentsRepository {
  Stream<List<CommentModel>> getCommentsStream(String postId);

  Future<void> addComment({
    required String postId,
    required String comment,
  });

  Future<void> removeComment({
    required String postId,
    required String commentId,
  });

  Future<void> addCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  });

  Future<void> deleteCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  });
}