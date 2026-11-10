import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../fakes/fake_user_account_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/interactions/comments_likes/domain/data_sources/comments_likes_data_source.dart';
import 'package:social_app/features/interactions/comments_likes/data/data_sources/comments_likes_data_source_impl.dart';


void main() {
  late MockSessionService mockSession;
  late CommentsLikesDataSource dataSource;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeUserAccountService fakeAccountService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    dataSource = CommentsLikesDataSourceImpl(
      firestore: fakeFirestore,
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('getCommentLikesStream', () {
    test('emits empty when no likes', () async {
      final stream = dataSource.getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      );

      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('emits MyModel list when likes exist', () async {
      // like من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('uid-2')
          .set({});

      // account uid-2
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set({
        AppStrings.userName: 'Sara',
      });

      fakeAccountService.getUserAccountResult = {AppStrings.userName: 'Sara'};

      final stream = dataSource.getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first, isA<MyModel>());
    });

    test('skips likes when account does not exist', () async {
      // like من missing-user
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('missing-user')
          .set({});

      final stream = dataSource.getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('sets isFriend based on friends list', () async {
      // friends — uid-2
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .doc('uid-2')
          .set({});

      // like من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('uid-2')
          .set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set({
        AppStrings.userName: 'Sara',
      });

      fakeAccountService.getUserAccountResult = {AppStrings.userName: 'Sara'};

      final stream = dataSource.getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      );
      final result = await stream.first;

      expect(result.length, 1);
    });

    test('calls getUserAccount for each like', () async {
      // 2 likes
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('uid-2')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('uid-3')
          .set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set({});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-3').set({});

      fakeAccountService.getUserAccountResult = {AppStrings.userName: 'X'};

      final stream = dataSource.getCommentLikesStream(
        postId: 'post-1',
        commentId: 'comment-1',
      );
      await stream.first;

      expect(fakeAccountService.getUserAccountCallCount, 2);
    });
  });
}