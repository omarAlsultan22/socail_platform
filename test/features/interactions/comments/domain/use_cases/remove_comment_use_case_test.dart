import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_repository.dart';
import 'package:social_app/features/interactions/comments/domain/use_cases/remove_comment_use_case.dart';


void main() {
  late FakeCommentsRepository fakeRepo;
  late RemoveCommentUseCase useCase;

  setUp(() {
    fakeRepo = FakeCommentsRepository();
    useCase = RemoveCommentUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.removeComment with postId and commentId',
            () async {
          await useCase.call(
            postId: 'post-1',
            commentId: 'comment-1',
          );

          expect(fakeRepo.removeCommentCallCount, 1);
          expect(fakeRepo.lastRemovePostId, 'post-1');
          expect(fakeRepo.lastRemoveCommentId, 'comment-1');
        });

    test('passes different params correctly', () async {
      await useCase.call(
        postId: 'custom-post',
        commentId: 'custom-comment',
      );

      expect(fakeRepo.lastRemovePostId, 'custom-post');
      expect(fakeRepo.lastRemoveCommentId, 'custom-comment');
    });

    test('propagates errors from repository', () async {
      fakeRepo.removeCommentError = Exception('delete failed');

      expect(
            () =>
            useCase.call(
              postId: 'post-1',
              commentId: 'comment-1',
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}