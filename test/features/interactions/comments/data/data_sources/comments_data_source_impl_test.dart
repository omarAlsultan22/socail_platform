import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../fakes/fake_user_account_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/interactions/comments/domain/data_sources/comments_data_source.dart';
import 'package:social_app/features/interactions/comments/data/data_sources/comments_data_source_impl.dart';


void main() {
  late CommentsDataSource dataSource;
  late MockSessionService mockSession;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeUserAccountService fakeAccountService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    dataSource = CommentsDataSourceImpl(
      firestore: fakeFirestore,
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('getCommentsStream', () {
    test('emits empty list when no comments', () async {
      final stream = dataSource.getCommentsStream('post-1');

      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('emits comments with user data and counts', () async {
      // post + comment
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({
        AppStrings.userId: 'uid-2',
        'userAction': 'Nice',
        'myDateTime': DateTime(2024, 5, 1),
      });

      // account
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            AppStrings.userName: 'Sara',
          });
      fakeAccountService.getAccountMapResult = {AppStrings.userName: 'Sara'};

      final stream = dataSource.getCommentsStream('post-1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first, isA<CommentModel>());
    });

    test('skips comments without userId', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({
        // لا userId
        'userAction': 'Nice',
      });

      final stream = dataSource.getCommentsStream('post-1');
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('skips comments when account does not exist', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({
        AppStrings.userId: 'missing-user',
        'userAction': 'Nice',
      });

      final stream = dataSource.getCommentsStream('post-1');
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  group('addComment', () {
    test('adds comment when account exists', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
          });
      fakeAccountService.getAccountMapResult = {AppStrings.userName: 'Ali'};

      await dataSource.addComment(postId: 'post-1', comment: 'Great post!');

      final comments = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      expect(comments.docs.length, 1);
      expect(comments.docs.first.data()['userAction'], 'Great post!');
    });

    test('does nothing when account does not exist', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});

      await dataSource.addComment(postId: 'post-1', comment: 'Great post!');

      final comments = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      expect(comments.docs, isEmpty);
    });
  });

  group('removeComment', () {
    test('deletes the comment', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({'text': 'Hello'});

      await dataSource.removeComment(postId: 'post-1', commentId: 'comment-1');

      final comment = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .get();

      expect(comment.exists, false);
    });
  });

  group('addCommentLike', () {
    test('adds like and sets isActive true when current user is owner',
            () async {
          await fakeFirestore.collection(FirestoreSchema.posts)
              .doc('post-1')
              .set({});
          await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .set({AppStrings.isActive: false});

          await dataSource.addCommentLike(
            postId: 'post-1',
            commentId: 'comment-1',
            commentOwnerId: 'uid-1', // ← current user
          );

          // isActive — true
          final comment = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .get();
          expect(comment.data()?[AppStrings.isActive], true);

          // like — created
          final like = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .collection(AppStrings.commentsLikes)
              .doc('uid-1')
              .get();
          expect(like.exists, true);
        });

    test('adds like without isActive when not owner', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({AppStrings.isActive: false});

      await dataSource.addCommentLike(
        postId: 'post-1',
        commentId: 'comment-1',
        commentOwnerId: 'other-user', // ← ليس current
      );

      // isActive — false (لم يتغير)
      final comment = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .get();
      expect(comment.data()?[AppStrings.isActive], false);

      // like — created
      final like = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('uid-1')
          .get();
      expect(like.exists, true);
    });
  });

  group('deleteCommentLike', () {
    test('removes like and sets isActive false when current user is owner',
            () async {
          await fakeFirestore.collection(FirestoreSchema.posts)
              .doc('post-1')
              .set({});
          await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .set({AppStrings.isActive: true});
          await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .collection(AppStrings.commentsLikes)
              .doc('uid-1')
              .set({});

          await dataSource.deleteCommentLike(
            postId: 'post-1',
            commentId: 'comment-1',
            commentOwnerId: 'uid-1',
          );

          // isActive — false
          final comment = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .get();
          expect(comment.data()?[AppStrings.isActive], false);

          // like — deleted
          final like = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.commentsList)
              .doc('comment-1')
              .collection(AppStrings.commentsLikes)
              .doc('uid-1')
              .get();
          expect(like.exists, false);
        });
  });
}