import '../datasources/comments_remote_datasource.dart';
import '../../domain/repository/comments_repository.dart';
import 'package:social_app/core/data/models/comment_model.dart';


class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return remoteDataSource.getCommentsStream(postId).map(
          (comments) => comments
          .map((c) => CommentModel(
        docId: c.docId,
        postId: c.postId,
        myId: c.myId,
        userAction: c.userAction,
        myDateTime: c.myDateTime,
        likesNumber: c.likesNumber ?? 0,
        hasMeLiked: c.hasMeLiked,
      )).toList(),
    );
  }

  @override
  Future<void> addComment({
    required String postId,
    required String comment,
  }) {
    return remoteDataSource.addComment(postId: postId, comment: comment);
  }

  @override
  Future<void> removeComment({
    required String postId,
    required String commentId,
  }) {
    return remoteDataSource.removeComment(postId: postId, commentId: commentId);
  }

  @override
  Future<void> addCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) {
    return remoteDataSource.addCommentLike(
      postId: postId,
      commentId: commentId,
      commentOwnerId: commentOwnerId,
    );
  }

  @override
  Future<void> deleteCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) {
    return remoteDataSource.deleteCommentLike(
      postId: postId,
      commentId: commentId,
      commentOwnerId: commentOwnerId,
    );
  }
}