import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/interactions/comments/domain/data_sources/comments_data_source.dart';


class FakeCommentsDataSource implements CommentsDataSource {
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

  @override
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    addCommentCallCount++;
    lastAddPostId = postId;
    lastAddComment = comment;
  }

  // ===== removeComment =====
  int removeCommentCallCount = 0;
  String? lastRemovePostId;
  String? lastRemoveCommentId;

  @override
  Future<void> removeComment({
    required String postId,
    required String commentId,
  }) async {
    removeCommentCallCount++;
    lastRemovePostId = postId;
    lastRemoveCommentId = commentId;
  }

  // ===== addCommentLike =====
  int addCommentLikeCallCount = 0;
  String? lastAddLikePostId;
  String? lastAddLikeCommentId;
  String? lastAddLikeOwnerId;

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
  }

  // ===== deleteCommentLike =====
  int deleteCommentLikeCallCount = 0;
  String? lastDeleteLikePostId;
  String? lastDeleteLikeCommentId;
  String? lastDeleteLikeOwnerId;

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
  }

  // باقي دوال FirestoreService — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeCommentsDataSource.${invocation.memberName} not stubbed',
      );
}