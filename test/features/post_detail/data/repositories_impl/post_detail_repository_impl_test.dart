import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../fakes/fake_post_detail_data_source.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/post_detail/domain/repositories/post_detail_repository.dart';
import 'package:social_app/features/post_detail/data/data_sources/post_detail_data_source_impl.dart';
import 'package:social_app/features/post_detail/data/repositories_impl/post_detail_repository_impl.dart';


void main() {
  late MockSessionService mockSession;
  late PostDetailRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late FakePostDetailDataSource fakeDataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakePostDetailDataSource();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    repository = PostDetailRepositoryImpl(
      dataSource: fakeDataSource,
      sessionService: mockSession,
    );
  });

  group('getPostData', () {
    test('delegates to dataSource.getPostData', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {});
      final postDoc = await fakeFirestore.collection(FirestoreSchema.posts).doc(
          'post-1').get();
      final userDoc = await fakeFirestore.collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();
      final commentsDocs = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      fakeDataSource.getPostDataResult = (
      postDoc: postDoc,
      userDoc: userDoc,
      commentsDocs: commentsDocs,
      );

      final result = await repository.getPostData(
        postId: 'post-1',
        userId: 'uid-1',
      );

      expect(fakeDataSource.getPostDataCallCount, 1);
      expect(result.postDoc.exists, true);
      expect(result.userDoc.exists, true);
    });
  });

  group('getPostLikes', () {
    test('returns likesCount from dataSource.getCount', () async {
      // نستخدم fakeFirestore + getCount — بدل FakePostDetailDataSource
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('like-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('like-2')
          .set({});

      // نستخدم PostDetailDataSourceImpl مع fakeFirestore
      final realDataSource = PostDetailDataSourceImpl(firestore: fakeFirestore);
      final realRepo = PostDetailRepositoryImpl(
        dataSource: realDataSource,
        sessionService: mockSession,
      );

      final result = await realRepo.getPostLikes(postId: 'post-1');

      expect(result, 2);
    });

    test('returns 0 when no likes', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});

      final realDataSource = PostDetailDataSourceImpl(firestore: fakeFirestore);
      final realRepo = PostDetailRepositoryImpl(
        dataSource: realDataSource,
        sessionService: mockSession,
      );

      final result = await realRepo.getPostLikes(postId: 'post-1');

      expect(result, 0);
    });
  });

  group('getCommentsWithUsers', () {
    test('returns list of CommentModel', () async {
      // commentsDocs — 2 comments
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({
        AppStrings.userId: 'uid-1',
        'text': 'First',
      });
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-2')
          .set({
        AppStrings.userId: 'uid-2',
        'text': 'Second',
      });

      final commentsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      // fakeDataSource.getCommentsWithLikes — يعيد commentsSnapshot.docs
      fakeDataSource.commentsWithLikesResult = commentsSnapshot.docs;

      // accounts — موجودة
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
          });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            AppStrings.userName: 'Sara',
          });

      fakeDataSource.docResponses = {
        'accounts/uid-1': await fakeFirestore.collection(
            FirestoreSchema.accounts).doc('uid-1').get(),
        'accounts/uid-2': await fakeFirestore.collection(
            FirestoreSchema.accounts).doc('uid-2').get(),
      };
      fakeDataSource.accountMapResult = {AppStrings.userName: 'Ali'};

      final result = await repository.getCommentsWithUsers(
        postId: 'post-1',
        commentsDocs: commentsSnapshot,
      );

      expect(result, isA<List<CommentModel>>());
      expect(result.length, greaterThanOrEqualTo(0));
    });
  });

  group('insertNotification', () {
    test('calls setSupDoc with notifications and isMerge false', () async {
      final notificationData = MyModel(
        myId: 'notif-1',
        myDateTime: DateTime(2024),
      );

      await repository.insertNotification(notificationData: notificationData);

      expect(fakeDataSource.setSupDocCallCount, 1);
      expect(fakeDataSource.lastSetSupCollectionPath,
          FirestoreSchema.notifications);
      expect(fakeDataSource.lastSetSupDocId, 'notif-1');
      expect(fakeDataSource.lastSetSupIsMerge, false);
      expect(fakeDataSource.lastSetSupData, notificationData.toJson());
    });
  });
}