import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/comment_model.dart';


abstract class PostDetailRepository {
  Future<({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  });

  Future<int> getPostLikesCount({required String postId});

  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs
  });

  Future<void> insertNotification({
    required UserModel notificationData,
  });
}