import '../repository/comments_repository.dart';
import '../../../../../core/data/models/comment_model.dart';


class GetCommentsStreamUseCase {
  final CommentsRepository repository;

  GetCommentsStreamUseCase({required this.repository});

  Stream<List<CommentModel>> call(String postId) {
    return repository.getCommentsStream(postId);
  }
}