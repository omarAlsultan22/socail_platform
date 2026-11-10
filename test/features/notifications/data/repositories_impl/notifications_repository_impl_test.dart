import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../fakes/fake_notifications_data_source.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';
import 'package:social_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:social_app/features/notifications/data/repositories_impl/notifications_repository_impl.dart';


void main() {
  late FakeNotificationsDataSource fakeDataSource;
  late FakeFirebaseFirestore fakeFirestore;
  late NotificationsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeNotificationsDataSource();
    repository = NotificationsRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getNotificationsStream', () {
    test('delegates to dataSource.getNotificationsStream', () {
      fakeDataSource.notificationsStream = const Stream.empty();

      repository.getNotificationsStream(userId: 'uid-1');

      expect(fakeDataSource.getNotificationsStreamCallCount, 1);
      expect(fakeDataSource.lastNotificationsUserId, 'uid-1');
    });
  });

  group('convertNotificationsToModels', () {
    test('returns list of NotificationsModel', () async {
      // 1 notification
      await fakeFirestore.collection(FirestoreSchema.notifications)
          .doc('n1')
          .set({
        AppStrings.friendId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });

      // account
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
            AppStrings.userImage: 'url',
          });

      final notificationsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.notifications)
          .get();

      final accountDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();
      fakeDataSource.docResponses = {'accounts/uid-1': accountDoc};

      final result = await repository.convertNotificationsToModels(
        notificationsSnapshot: notificationsSnapshot,
      );

      expect(result, isA<List<NotificationsModel>>());
    });

    test('returns empty list for empty snapshot', () async {
      final emptySnapshot = await fakeFirestore
          .collection(FirestoreSchema.notifications)
          .get();

      final result = await repository.convertNotificationsToModels(
        notificationsSnapshot: emptySnapshot,
      );

      expect(result, isEmpty);
    });
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
    });
  });

  group('getPostLikesCount', () {
    test('delegates to dataSource.getPostLikesCount', () async {
      fakeDataSource.getPostLikesCountResult = 5;

      final result = await repository.getPostLikesCount(postId: 'post-1');

      expect(result, 5);
      expect(fakeDataSource.getPostLikesCountCallCount, 1);
    });
  });

  group('getCommentsWithUsers', () {
    test('returns list of CommentModel', () async {
      // commentsDocs
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({
        AppStrings.userId: 'uid-1',
        'text': 'First',
      });

      final commentsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      fakeDataSource.commentsWithLikesResult = commentsSnapshot.docs;

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
          });
      final accountDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();
      fakeDataSource.docResponses = {'accounts/uid-1': accountDoc};
      fakeDataSource.getAccountMapResult = {AppStrings.userName: 'Ali'};

      final result = await repository.getCommentsWithUsers(
        postId: 'post-1',
        commentsDocs: commentsSnapshot,
      );

      expect(result, isA<List<CommentModel>>());
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
      expect(fakeDataSource.lastSetSupIsMerge, false);
    });
  });

  group('updateNotificationReadStatus', () {
    test('calls updateDoc with isRead true', () async {
      await repository.updateNotificationReadStatus(docId: 'notif-1');

      expect(fakeDataSource.updateDocCallCount, 1);
      expect(fakeDataSource.lastUpdateDocId, 'notif-1');
      expect(fakeDataSource.lastUpdateDocCollectionPath,
          FirestoreSchema.notifications);
      expect(fakeDataSource.lastUpdateDocData, {AppStrings.isRead: true});
    });
  });
}