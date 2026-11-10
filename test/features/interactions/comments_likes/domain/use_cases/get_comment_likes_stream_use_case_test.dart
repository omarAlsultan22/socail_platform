import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../../fakes/fake_comments_likes_repository.dart';
import 'package:social_app/features/interactions/comments_likes/domain/use_cases/get_comment_likes_stream_use_case.dart';


void main() {
  late FakeCommentsLikesRepository fakeRepo;
  late GetCommentLikesStreamUseCase useCase;

  setUp(() {
    fakeRepo = FakeCommentsLikesRepository();
    useCase = GetCommentLikesStreamUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository with postId and commentId', () async {
      fakeRepo.commentLikesStream = Stream.value([]);

      await useCase
          .call(
        postId: 'post-1',
        commentId: 'comment-1',
      )
          .first;

      expect(fakeRepo.getCommentLikesStreamCallCount, 1);
      expect(fakeRepo.lastPostId, 'post-1');
      expect(fakeRepo.lastCommentId, 'comment-1');
    });

    test('returns stream from repository', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeRepo.commentLikesStream = Stream.value([model]);

      final result = await useCase
          .call(
        postId: 'post-1',
        commentId: 'comment-1',
      )
          .first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
    });

    test('propagates errors from repository', () async {
      fakeRepo.commentLikesStream = Stream.error(Exception('stream failed'));

      expect(
            () =>
        useCase
            .call(
          postId: 'post-1',
          commentId: 'comment-1',
        )
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}