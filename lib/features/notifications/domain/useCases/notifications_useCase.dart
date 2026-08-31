import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/comment_model.dart';
import '../repositories/notifications_repository.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class NotificationsUseCases {
  final NotificationsRepository _repository;

  NotificationsUseCases({required NotificationsRepository repository})
      : _repository = repository;

  Future<void> executeInsertNotification({
    required String userUid,
    required String userImage,
    required String userName,
    required String userAction,
  }) async {
    final notificationData = UserModel(
      userId: userUid,
      userImage: userImage,
      userName: userName,
    );

    await _repository.insertNotification(notificationData: notificationData);
  }

  Stream<List<NotificationsModel>> executeGetNotificationsStream({
    required String userId,
  }) {
    return _repository.getNotificationsStream(userId: userId).asyncMap(
            (notificationsSnapshot) async {
          return await _repository.convertNotificationsToModels(
            notificationsSnapshot: notificationsSnapshot,
          );
        }
    );
  }

  Future<({
  PostModel post,
  List<CommentModel> comments,
  })> executeGetPostData({
    required String userId,
    required String postId,
  }) async {
    // 1. جلب البيانات الأساسية
    final postData = await _repository.getPostData(
      postId: postId,
      userId: userId,
    );

    if (!postData.postDoc.exists || !postData.userDoc.exists) {
      throw Exception('Post or user not found');
    }

    // 2. جلب بيانات المستخدم
    final userAccount = await _getAccountMap(userDoc: postData.userDoc);

    // 3. جلب عدد اللايكات
    final likesCount = await _repository.getPostLikesCount(postId: postId);

    // 4. جلب التعليقات
    final comments = await _repository.getCommentsWithUsers(
      commentsDocs: postData.commentsDocs,
      postId: postId,
    );

    // 5. إنشاء البوست
    final postDocData = postData.postDoc.data() as Map<String, dynamic>;
    final post = PostModel.fromFirestoreToPost({
      ...userAccount,
      ...postDocData,
      'likesNumber': likesCount,
      'commentsNumber': comments.length,
    });

    return (
    post: post,
    comments: comments,
    );
  }

  Future<void> executeUpdateNotificationsCounter({
    required String docId,
  }) async {
    await _repository.updateNotificationReadStatus(docId: docId);
  }

  // دالة مساعدة خاصة
  Future<Map<String, dynamic>> _getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    return {
      'userImage': userData['userImage'] ?? '',
      'userName': userData['userName'] ?? '',
      'userId': userDoc.id,
    };
  }
}