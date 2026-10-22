import '../../domain/repository/comments_repository.dart';
import '../../domain/data_sources/comments_data_source.dart';
import 'package:social_app/core/data/models/comment_model.dart';


class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsDataSource _dataSource;

  CommentsRepositoryImpl({required CommentsDataSource dataSource}) :
        _dataSource = dataSource;

  @override
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _dataSource.getCommentsStream(postId).map(
          (comments) =>
          comments
              .map((c) =>
              CommentModel(
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
    return _dataSource.addComment(postId: postId, comment: comment);
  }

  @override
  Future<void> removeComment({
    required String postId,
    required String commentId,
  }) {
    return _dataSource.removeComment(postId: postId, commentId: commentId);
  }

  @override
  Future<void> addCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) {
    return _dataSource.addCommentLike(
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
    return _dataSource.deleteCommentLike(
      postId: postId,
      commentId: commentId,
      commentOwnerId: commentOwnerId,
    );
  }
}