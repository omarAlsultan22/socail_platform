import '../repository/comments_likes_repository.dart';
import '../../../../../core/data/models/my_model.dart';


class GetCommentLikesStreamUseCase {
  final CommentsLikesRepository _repository;

  GetCommentLikesStreamUseCase({required CommentsLikesRepository repository})
      : _repository = repository;

  Stream<List<MyModel>> call({
    required String postId,
    required String commentId,
  }) {
    return _repository.getCommentLikesStream(
      postId: postId,
      commentId: commentId,
    );
  }
}