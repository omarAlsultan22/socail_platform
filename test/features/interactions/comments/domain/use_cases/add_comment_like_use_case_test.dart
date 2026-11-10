import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_repository.dart';
import 'package:social_app/features/interactions/comments/domain/use_cases/add_comment_like_use_case.dart';


void main() {
  late AddCommentLikeUseCase useCase;
  late FakeCommentsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeCommentsRepository();
    useCase = AddCommentLikeUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.addCommentLike with all params', () async {
      await useCase.call(
        postId: 'post-1',
        commentId: 'comment-1',
        commentOwnerId: 'owner-1',
      );

      expect(fakeRepo.addCommentLikeCallCount, 1);
      expect(fakeRepo.lastAddLikePostId, 'post-1');
      expect(fakeRepo.lastAddLikeCommentId, 'comment-1');
      expect(fakeRepo.lastAddLikeOwnerId, 'owner-1');
    });

    test('passes different params correctly', () async {
      await useCase.call(
        postId: 'custom-post',
        commentId: 'custom-comment',
        commentOwnerId: 'custom-owner',
      );

      expect(fakeRepo.lastAddLikePostId, 'custom-post');
      expect(fakeRepo.lastAddLikeCommentId, 'custom-comment');
      expect(fakeRepo.lastAddLikeOwnerId, 'custom-owner');
    });

    test('propagates errors from repository', () async {
      fakeRepo.addCommentLikeError = Exception('like failed');

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