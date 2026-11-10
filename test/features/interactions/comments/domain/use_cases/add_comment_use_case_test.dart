import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_repository.dart';
import 'package:social_app/features/interactions/comments/domain/use_cases/add_comment_use_case.dart';


void main() {
  late FakeCommentsRepository fakeRepo;
  late AddCommentUseCase useCase;

  setUp(() {
    fakeRepo = FakeCommentsRepository();
    useCase = AddCommentUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.addComment with postId and comment',
            () async {
          await useCase.call(
            postId: 'post-1',
            comment: 'Nice post!',
          );

          expect(fakeRepo.addCommentCallCount, 1);
          expect(fakeRepo.lastAddPostId, 'post-1');
          expect(fakeRepo.lastAddComment, 'Nice post!');
        });

    test('passes different params correctly', () async {
      await useCase.call(
        postId: 'custom-post',
        comment: 'Custom comment',
      );

      expect(fakeRepo.lastAddPostId, 'custom-post');
      expect(fakeRepo.lastAddComment, 'Custom comment');
    });

    test('propagates errors from repository', () async {
      fakeRepo.addCommentError = Exception('comment failed');

      expect(
            () =>
            useCase.call(
              postId: 'post-1',
              comment: 'Nice post!',
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}