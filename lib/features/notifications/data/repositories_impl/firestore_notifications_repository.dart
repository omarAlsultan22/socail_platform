import 'package:cloud_firestore/cloud_firestore.dart';
import '../converters/notification_data_converter.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../data_sources/remote/firestore_notifications_service.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class FirestoreNotificationsRepository implements NotificationsRepository {
  final FirestoreNotificationsService _repository;

  FirestoreNotificationsRepository({
    required FirestoreNotificationsService repository
  })
      : _repository = repository;

  @override
  Stream<QuerySnapshot> getNotificationsStream({
    required String userId,
  }) {
    return _repository.getNotificationsStream(userId: userId);
  }

  @override
  Future<List<NotificationsModel>> convertNotificationsToModels({
    required QuerySnapshot notificationsSnapshot,
  }) async {
    final List<NotificationsModel> result = [];
    final notifications = notificationsSnapshot.docs;

    await Future.wait(notifications.map((notificationDoc) async {
      try {
        final userId = notificationDoc['friendId'];
        final userAccount = await _repository.getSupDoc(
          docId: userId, collectionPath: 'accounts',
        );

        final notificationData = await NotificationsDataConverter
            .fromDocumentSnapshot(
            userAccountDoc: userAccount,
            notificationDoc: notificationDoc,
        );

        result.add(notificationData.notificationsModel);
      } catch (error) {
        rethrow;
      }
    }));

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
    return await _repository.getPostData(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<int> getPostLikesCount({required String postId}) async {
    return await _repository.getPostLikesCount(postId: postId);
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await _repository.getCommentsWithLikes(
      postId: postId,
      commentsDocs: commentsDocs,
    );

    final comments = await Future.wait(
      commentsWithLikes.map((doc) async {
        final commentData = doc.data();
        final commentUserDoc = await _repository.getSupDoc(
            docId: commentData['userId'], collectionPath: 'accounts'
        );

        if (!commentUserDoc.exists) return null;

        final userAccount = await _repository.getAccountMap(
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
    required UserModel notificationData,
  }) async {
    await _repository.setSupDoc(
      isMerge: false,
      docId: notificationData.userId,
      data: notificationData.toJson(),
      collectionPath: 'notifications',
    );
  }

  @override
  Future<void> updateNotificationReadStatus({
    required String docId,
  }) async {
    await _repository.updateDoc(
        docId: docId,
        data: {'isRead': true},
        collectionPath: 'notifications'
    );
  }
}