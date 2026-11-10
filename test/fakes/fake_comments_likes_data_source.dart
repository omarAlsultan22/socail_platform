import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/comments_likes/domain/data_sources/comments_likes_data_source.dart';


class FakeCommentsLikesDataSource implements CommentsLikesDataSource {
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

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeCommentsLikesDataSource.${invocation.memberName} not stubbed',
      );
}