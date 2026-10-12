import '../repository/comments_repository.dart';


class AddCommentUseCase {
  final CommentsRepository _repository;

  AddCommentUseCase({required CommentsRepository repository})
      : _repository = repository;

  Future<void> call({
    required String postId,
    required String comment,
  }) {
    return _repository.addComment(postId: postId, comment: comment);
  }
}