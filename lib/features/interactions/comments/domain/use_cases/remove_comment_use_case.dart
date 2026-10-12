import '../repository/comments_repository.dart';


class RemoveCommentUseCase {
  final CommentsRepository _repository;

  RemoveCommentUseCase({required CommentsRepository repository})
      : _repository = repository;

  Future<void> call({
    required String postId,
    required String commentId,
  }) {
    return _repository.removeComment(postId: postId, commentId: commentId);
  }
}