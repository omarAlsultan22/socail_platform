import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/comments_likes/domain/repository/comments_likes_repository.dart';


class FakeCommentsLikesRepository implements CommentsLikesRepository {
  Stream<List<MyModel>>? commentLikesStream;
  int getCommentLikesStreamCallCount = 0;
  String? lastPostId;
  String? lastCommentId;

  @override
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  }) {
    getCommentLikesStreamCallCount++;
    lastPostId = postId;
    lastCommentId = commentId;
    return commentLikesStream!;
  }
}