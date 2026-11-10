import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/interactions/comments/domain/repository/comments_repository.dart';


class FakeCommentsRepository implements CommentsRepository {
  // ===== getCommentsStream =====
  Stream<List<CommentModel>>? commentsStream;
  int getCommentsStreamCallCount = 0;
  String? lastPostId;

  @override
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    getCommentsStreamCallCount++;
    lastPostId = postId;
    return commentsStream!;
  }

  // ===== addComment =====
  int addCommentCallCount = 0;
  String? lastAddPostId;
  String? lastAddComment;
  Object? addCommentError;

  @override
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    addCommentCallCount++;
    lastAddPostId = postId;
    lastAddComment = comment;
    if (addCommentError != null) throw addCommentError!;
  }

  // ===== removeComment =====
  int removeCommentCallCount = 0;
  String? lastRemovePostId;
  String? lastRemoveCommentId;
  Object? removeCommentError;

  @override
  Future<void> removeComment({
    required String postId,
    required String commentId,
  }) async {
    removeCommentCallCount++;
    lastRemovePostId = postId;
    lastRemoveCommentId = commentId;
    if (removeCommentError != null) throw removeCommentError!;
  }

  // ===== addCommentLike =====
  int addCommentLikeCallCount = 0;
  String? lastAddLikePostId;
  String? lastAddLikeCommentId;
  String? lastAddLikeOwnerId;
  Object? addCommentLikeError;

  @override
  Future<void> addCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) async {
    addCommentLikeCallCount++;
    lastAddLikePostId = postId;
    lastAddLikeCommentId = commentId;
    lastAddLikeOwnerId = commentOwnerId;
    if (addCommentLikeError != null) throw addCommentLikeError!;
  }

  // ===== deleteCommentLike =====
  int deleteCommentLikeCallCount = 0;
  String? lastDeleteLikePostId;
  String? lastDeleteLikeCommentId;
  String? lastDeleteLikeOwnerId;
  Object? deleteCommentLikeError;

  @override
  Future<void> deleteCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) async {
    deleteCommentLikeCallCount++;
    lastDeleteLikePostId = postId;
    lastDeleteLikeCommentId = commentId;
    lastDeleteLikeOwnerId = commentOwnerId;
    if (deleteCommentLikeError != null) throw deleteCommentLikeError!;
  }
}