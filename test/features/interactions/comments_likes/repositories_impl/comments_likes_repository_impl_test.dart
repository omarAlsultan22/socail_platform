import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../fakes/fake_comments_likes_data_source.dart';
import 'package:social_app/features/interactions/comments_likes/domain/repository/comments_likes_repository.dart';
import 'package:social_app/features/interactions/comments_likes/data/repository_impl/comments_likes_repository_impl.dart';


void main() {
  late CommentsLikesRepository repository;
  late FakeCommentsLikesDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCommentsLikesDataSource();
    repository = CommentsLikesRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getCommentLikesStream', () {
    test('delegates to dataSource with postId and commentId', () async {
      fakeDataSource.commentLikesStream = Stream.value([]);

      await repository
          .getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      )
          .first;

      expect(fakeDataSource.getCommentLikesStreamCallCount, 1);
      expect(fakeDataSource.lastPostId, 'post-1');
      expect(fakeDataSource.lastCommentId, 'comment-1');
    });

    test('maps MyModel preserving myId and myDateTime', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeDataSource.commentLikesStream = Stream.value([model]);

      final result = await repository
          .getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      )
          .first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
      expect(result.first.myDateTime, DateTime(2024, 5, 1));
    });

    test('returns empty list for empty stream', () async {
      fakeDataSource.commentLikesStream = Stream.value([]);

      final result = await repository
          .getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      )
          .first;

      expect(result, isEmpty);
    });

    test('propagates errors from dataSource', () async {
      fakeDataSource.commentLikesStream =
          Stream.error(Exception('stream failed'));

      expect(
            () =>
        repository
            .getCommentLikesStream(
          postId: 'post-1',
          commentId: 'comment-1',
        )
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}