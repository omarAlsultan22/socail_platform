import '../repository/comments_repository.dart';


class AddCommentLikeUseCase {
  final CommentsRepository _repository;

  AddCommentLikeUseCase({required CommentsRepository repository})
      : _repository = repository;

  Future<void> call({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) {
    return _repository.addCommentLike(
      postId: postId,
      commentId: commentId,
      commentOwnerId: commentOwnerId,
    );
  }
}