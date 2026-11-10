import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_comments_data_source.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/interactions/comments/domain/repository/comments_repository.dart';
import 'package:social_app/features/interactions/comments/data/repository_impl/comments_repository_impl.dart';


void main() {
  late CommentsRepository repository;
  late FakeCommentsDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCommentsDataSource();
    repository = CommentsRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getCommentsStream', () {
    test('delegates to dataSource.getCommentsStream with postId', () async {
      fakeDataSource.commentsStream = Stream.value([]);

      await repository
          .getCommentsStream('post-1')
          .first;

      expect(fakeDataSource.getCommentsStreamCallCount, 1);
      expect(fakeDataSource.lastPostId, 'post-1');
    });

    test('maps CommentModel with likesNumber default 0', () async {
      final comment = CommentModel(
        docId: 'comment-1',
        postId: 'post-1',
        myId: 'uid-1',
        userAction: 'Nice',
        myDateTime: DateTime(2024, 5, 1),
        hasMeLiked: false,
        likesNumber: null, // ← null — يُعاد 0
      );

      fakeDataSource.commentsStream = Stream.value([comment]);

      final result = await repository
          .getCommentsStream('post-1')
          .first;

      expect(result.length, 1);
      expect(result.first.likesNumber, 0); // ← 0 بدل null
    });

    test('preserves CommentModel fields', () async {
      final comment = CommentModel(
        docId: 'comment-1',
        postId: 'post-1',
        myId: 'uid-1',
        userAction: 'Nice',
        myDateTime: DateTime(2024, 5, 1),
        hasMeLiked: true,
        likesNumber: 5,
      );

      fakeDataSource.commentsStream = Stream.value([comment]);

      final result = await repository
          .getCommentsStream('post-1')
          .first;

      expect(result.first.docId, 'comment-1');
      expect(result.first.postId, 'post-1');
      expect(result.first.myId, 'uid-1');
      expect(result.first.userAction, 'Nice');
      expect(result.first.hasMeLiked, true);
      expect(result.first.likesNumber, 5);
    });

    test('returns empty list for empty stream', () async {
      fakeDataSource.commentsStream = Stream.value([]);

      final result = await repository
          .getCommentsStream('post-1')
          .first;

      expect(result, isEmpty);
    });
  });

  group('addComment', () {
    test('delegates to dataSource.addComment', () async {
      await repository.addComment(postId: 'post-1', comment: 'Nice');

      expect(fakeDataSource.addCommentCallCount, 1);
      expect(fakeDataSource.lastAddPostId, 'post-1');
      expect(fakeDataSource.lastAddComment, 'Nice');
    });
  });

  group('removeComment', () {
    test('delegates to dataSource.removeComment', () async {
      await repository.removeComment(postId: 'post-1', commentId: 'c-1');

      expect(fakeDataSource.removeCommentCallCount, 1);
      expect(fakeDataSource.lastRemovePostId, 'post-1');
      expect(fakeDataSource.lastRemoveCommentId, 'c-1');
    });
  });

  group('addCommentLike', () {
    test('delegates to dataSource.addCommentLike', () async {
      await repository.addCommentLike(
        postId: 'post-1',
        commentId: 'c-1',
        commentOwnerId: 'owner-1',
      );

      expect(fakeDataSource.addCommentLikeCallCount, 1);
      expect(fakeDataSource.lastAddLikePostId, 'post-1');
      expect(fakeDataSource.lastAddLikeCommentId, 'c-1');
      expect(fakeDataSource.lastAddLikeOwnerId, 'owner-1');
    });
  });

  group('deleteCommentLike', () {
    test('delegates to dataSource.deleteCommentLike', () async {
      await repository.deleteCommentLike(
        postId: 'post-1',
        commentId: 'c-1',
        commentOwnerId: 'owner-1',
      );

      expect(fakeDataSource.deleteCommentLikeCallCount, 1);
      expect(fakeDataSource.lastDeleteLikePostId, 'post-1');
      expect(fakeDataSource.lastDeleteLikeCommentId, 'c-1');
      expect(fakeDataSource.lastDeleteLikeOwnerId, 'owner-1');
    });
  });
}