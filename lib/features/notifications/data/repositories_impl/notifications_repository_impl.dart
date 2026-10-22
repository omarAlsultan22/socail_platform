import 'package:cloud_firestore/cloud_firestore.dart';
import '../converters/notification_data_converter.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/data_sources/notifications_data_source.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource _dataSource;

  NotificationsRepositoryImpl({
    required NotificationsDataSource dataSource
  })
      : _dataSource = dataSource;

  @override
  Stream<QuerySnapshot> getNotificationsStream({
    required String userId,
  }) {
    return _dataSource.getNotificationsStream(userId: userId);
  }

  @override
  Future<List<NotificationsModel>> convertNotificationsToModels({
    required QuerySnapshot notificationsSnapshot,
  }) async {
    final List<NotificationsModel> result = [];
    final notifications = notificationsSnapshot.docs;

    await Future.wait(
        notifications.map((notificationDoc) async {
          final userId = notificationDoc['friendId'];
          final userAccount = await _dataSource.getDoc(
            docId: userId, collectionPath: 'accounts',
          );

          final notificationData = await NotificationsDataConverter
              .fromDocumentSnapshot(
            userAccountDoc: userAccount,
            notificationDoc: notificationDoc,
          );

          result.add(notificationData.notificationsModel);
        })
    );

    return result;
  }

  @override
  Future<({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    return await _dataSource.getPostData(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<int> getPostLikesCount({required String postId}) async {
    return await _dataSource.getPostLikesCount(postId: postId);
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await _dataSource.getCommentsWithLikes(
      postId: postId,
      commentsDocs: commentsDocs,
    );

    final comments = await Future.wait(
      commentsWithLikes.map((doc) async {
        final commentData = doc.data();
        final commentUserDoc = await _dataSource.getDoc(
            docId: commentData['userId'], collectionPath: 'accounts'
        );

        if (!commentUserDoc.exists) return null;

        final userAccount = await _dataSource.getAccountMap(
          userDoc: commentUserDoc,
        );

        return CommentModel.fromJson({
          ...userAccount,
          ...commentData,
          'likesNumber': commentData['likesNumber'],
        });
      }),
    );

    return comments.whereType<CommentModel>().toList();
  }

  @override
  Future<void> insertNotification({
    required MyModel notificationData,
  }) async {
    await _dataSource.setSupDoc(
      isMerge: false,
      docId: notificationData.myId,
      data: notificationData.toJson(),
      collectionPath: 'notifications',
    );
  }

  @override
  Future<void> updateNotificationReadStatus({
    required String docId,
  }) async {
    await _dataSource.updateDoc(
        docId: docId,
        data: {'isRead': true},
        collectionPath: 'notifications'
    );
  }
}