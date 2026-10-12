import '../repository/comments_repository.dart';


class DeleteCommentLikeUseCase {
  final CommentsRepository _repository;

  DeleteCommentLikeUseCase({required CommentsRepository repository})
      : _repository = repository;

  Future<void> call({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) {
    return _repository.deleteCommentLike(
      postId: postId,
      commentId: commentId,
      commentOwnerId: commentOwnerId,
    );
  }
}