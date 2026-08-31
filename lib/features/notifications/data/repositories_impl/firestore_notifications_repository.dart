import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';
import '../converters/notification_data_converter.dart';
import '../../domain/repositories/notifications_repository.dart';


class FirestoreNotificationsRepository implements NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> getNotificationsStream({
    required String userId,
  }) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  @override
  Future<List<NotificationsModel>> convertNotificationsToModels({
    required QuerySnapshot notificationsSnapshot,
  }) async {
    final notifications = notificationsSnapshot.docs;
    final List<NotificationsModel> result = [];

    await Future.wait(notifications.map((notificationDoc) async {
      try {
        final userId = notificationDoc['friendId'];
        final userAccount = await _firestore
            .collection('accounts')
            .doc(userId)
            .get();

        final notificationData = await NotificationsDataConverter
            .fromDocumentSnapshot(
            userAccount, notificationDoc);
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
  QuerySnapshot commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);

    final results = await Future.wait([
      postRef.get(),
      _firestore.collection('accounts').doc(userId).get(),
      postRef.collection('commentsList').get(),
    ]);
    return (
    postDoc: results[0] as DocumentSnapshot,
    userDoc: results[1] as DocumentSnapshot,
    commentsDocs: results[2] as QuerySnapshot
    );
  }

  @override
  Future<int> getPostLikesCount({required String postId}) async {
    final likesCount = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likesList')
        .count()
        .get();
    return likesCount.count ?? 0;
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required QuerySnapshot commentsDocs,
    required String postId,
  }) async {
    final comments = await Future.wait(
      commentsDocs.docs.map((doc) async {
        final commentData = doc.data() as Map<String, dynamic>;
        final commentUserDoc = await _firestore
            .collection('accounts')
            .doc(commentData['userId'])
            .get();

        if (!commentUserDoc.exists) return null;

        final userAccount = await _getAccountMap(userDoc: commentUserDoc);
        final likesCount = await _firestore
            .collection('posts')
            .doc(postId)
            .collection('commentsList')
            .doc(doc.id)
            .collection('likesList')
            .count()
            .get();

        return CommentModel.fromJson({
          ...userAccount,
          ...commentData,
          'likesNumber': likesCount.count,
        });
      }),
    );

    return comments.whereType<CommentModel>().toList();
  }


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

  @override
  Future<void> insertNotification({
    required UserModel notificationData,
  }) async {
    await _firestore.collection('notifications')
        .doc(notificationData.userId)
        .set(notificationData.toJson());
  }

  @override
  Future<void> updateNotificationReadStatus({
    required String docId,
  }) async {
    await _firestore.collection('notifications').doc(docId).update(
      {'isRead': true},
    );
  }
}