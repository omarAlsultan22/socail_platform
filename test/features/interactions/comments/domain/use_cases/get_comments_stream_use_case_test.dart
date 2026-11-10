import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_repository.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/interactions/comments/domain/use_cases/get_comments_stream_use_case.dart';


void main() {
  late FakeCommentsRepository fakeRepo;
  late GetCommentsStreamUseCase useCase;

  setUp(() {
    fakeRepo = FakeCommentsRepository();
    useCase = GetCommentsStreamUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.getCommentsStream with postId', () async {
      fakeRepo.commentsStream = Stream.value([]);

      await useCase
          .call('post-1')
          .first;

      expect(fakeRepo.getCommentsStreamCallCount, 1);
      expect(fakeRepo.lastPostId, 'post-1');
    });

    test('returns the stream from repository', () async {
      final comment = CommentModel(
        docId: 'comment-1',
        postId: 'post-1',
        myId: 'uid-1',
        userAction: 'Nice',
        myDateTime: DateTime(2024, 5, 1),
        hasMeLiked: false,
        likesNumber: 0,
      );

      fakeRepo.commentsStream = Stream.value([comment]);

      final result = await useCase
          .call('post-1')
          .first;

      expect(result.length, 1);
      expect(result.first.docId, 'comment-1');
    });

    test('propagates errors from repository', () async {
      fakeRepo.commentsStream = Stream.error(Exception('stream failed'));

      expect(
            () =>
        useCase
            .call('post-1')
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}