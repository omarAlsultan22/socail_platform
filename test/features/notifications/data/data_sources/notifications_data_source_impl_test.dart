import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/notifications/data/data_sources/notifications_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NotificationsDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = NotificationsDataSourceImpl(firestore: fakeFirestore);
  });

  group('getNotificationsStream', () {
    test('emits notifications filtered by userId', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n1')
          .set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n2')
          .set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n3')
          .set({
        AppStrings.userId: 'uid-2',
        AppStrings.dateTime: DateTime(2024, 5, 3),
      });

      final stream = dataSource.getNotificationsStream(userId: 'uid-1');
      final snapshot = await stream.first;

      expect(snapshot.docs.length, 2);
      expect(
        snapshot.docs.every((d) => d.data()[AppStrings.userId] == 'uid-1'),
        true,
      );
    });

    test('orders notifications by dateTime descending', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n1')
          .set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n2')
          .set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 3),
      });
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n3')
          .set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });

      final stream = dataSource.getNotificationsStream(userId: 'uid-1');
      final snapshot = await stream.first;

      // الأحدث أولاً — n2 (May 3)
      expect(snapshot.docs.first.id, 'n2');
      expect(snapshot.docs.last.id, 'n1');
    });

    test('returns empty when no notifications', () async {
      final stream = dataSource.getNotificationsStream(userId: 'uid-1');
      final snapshot = await stream.first;

      expect(snapshot.docs, isEmpty);
    });
  });

  group('getPostData', () {
    test('returns post, user, and comments docs', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        AppStrings.userText: 'Hello',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
          });
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({'text': 'Nice'});

      final result = await dataSource.getPostData(
        postId: 'post-1',
        userId: 'uid-1',
      );

      expect(result.postDoc.exists, true);
      expect(result.userDoc.exists, true);
      expect(result.commentsDocs.docs.length, 1);
    });

    test('returns empty comments when no comments', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {});

      final result = await dataSource.getPostData(
        postId: 'post-1',
        userId: 'uid-1',
      );

      expect(result.commentsDocs.docs, isEmpty);
    });
  });

  group('getPostLikesCount', () {
    test('returns likes count', () async {
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

      final result = await dataSource.getPostLikesCount(postId: 'post-1');

      expect(result, 2);
    });

    test('returns 0 when no likes', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});

      final result = await dataSource.getPostLikesCount(postId: 'post-1');

      expect(result, 0);
    });
  });

  group('getCommentsWithLikes', () {
    test('adds likesCount to each comment', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});

      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({'text': 'First'});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-2')
          .set({'text': 'Second'});

      // 2 likes on comment-1
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.likesList)
          .doc('like-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.likesList)
          .doc('like-2')
          .set({});

      final commentsDocs = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      final result = await dataSource.getCommentsWithLikes(
        postId: 'post-1',
        commentsDocs: commentsDocs,
      );

      expect(result.length, 2);

      final comment1 = result.firstWhere((d) => d.id == 'comment-1');
      expect(comment1.data()[AppStrings.likesNumber], 2);

      final comment2 = result.firstWhere((d) => d.id == 'comment-2');
      expect(comment2.data()[AppStrings.likesNumber], 0);
    });
  });

  group('getAccountMap', () {
    test('returns userId, userName, userImage', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
            AppStrings.userImage: 'url',
          });
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();

      final result = await dataSource.getAccountMap(userDoc: userDoc);

      expect(result[AppStrings.userId], 'uid-1');
      expect(result[AppStrings.userName], 'Ali');
      expect(result[AppStrings.userImage], 'url');
    });

    test('returns empty strings when fields are missing', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {});
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();

      final result = await dataSource.getAccountMap(userDoc: userDoc);

      expect(result[AppStrings.userId], 'uid-1');
      expect(result[AppStrings.userName], AppStrings.empty);
      expect(result[AppStrings.userImage], AppStrings.empty);
    });
  });
}