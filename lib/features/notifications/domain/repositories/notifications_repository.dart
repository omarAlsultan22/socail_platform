import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


abstract class NotificationsRepository {

  Stream<QuerySnapshot> getNotificationsStream({
    required String userId,
  });

  Future<List<NotificationsModel>> convertNotificationsToModels({
    required QuerySnapshot notificationsSnapshot,
  });

  Future<({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  });

  Future<int> getPostLikesCount({required String postId});

  Future<List<CommentModel>> getCommentsWithUsers({
    required QuerySnapshot commentsDocs,
    required String postId,
  });

  Future<void> insertNotification({
    required UserModel notificationData,
  });

  Future<void> updateNotificationReadStatus({
    required String docId,
  });
}