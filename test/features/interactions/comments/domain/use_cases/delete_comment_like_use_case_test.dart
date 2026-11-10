import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_repository.dart';
import 'package:social_app/features/interactions/comments/domain/use_cases/delete_comment_like_use_case.dart';


void main() {
  late FakeCommentsRepository fakeRepo;
  late DeleteCommentLikeUseCase useCase;

  setUp(() {
    fakeRepo = FakeCommentsRepository();
    useCase = DeleteCommentLikeUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.deleteCommentLike with all params',
            () async {
          await useCase.call(
            postId: 'post-1',
            commentId: 'comment-1',
            commentOwnerId: 'owner-1',
          );

          expect(fakeRepo.deleteCommentLikeCallCount, 1);
          expect(fakeRepo.lastDeleteLikePostId, 'post-1');
          expect(fakeRepo.lastDeleteLikeCommentId, 'comment-1');
          expect(fakeRepo.lastDeleteLikeOwnerId, 'owner-1');
        });

    test('passes different params correctly', () async {
      await useCase.call(
        postId: 'custom-post',
        commentId: 'custom-comment',
        commentOwnerId: 'custom-owner',
      );

      expect(fakeRepo.lastDeleteLikePostId, 'custom-post');
      expect(fakeRepo.lastDeleteLikeCommentId, 'custom-comment');
      expect(fakeRepo.lastDeleteLikeOwnerId, 'custom-owner');
    });

    test('propagates errors from repository', () async {
      fakeRepo.deleteCommentLikeError = Exception('delete failed');

      expect(
            () =>
            useCase.call(
              postId: 'post-1',
              commentId: 'comment-1',
              commentOwnerId: 'owner-1',
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}