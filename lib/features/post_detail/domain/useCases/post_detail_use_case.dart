import '../../data/models/post_detail_model.dart';
import '../repositories/post_detail_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/services/session_service.dart';


class PostDetailUseCase {
  final PostDetailRepository _repository;

  PostDetailUseCase({
    required SessionService sessionService,
    required PostDetailRepository repository
  })
      : _repository = repository;

  Future<void> executeInsertNotification({
    required String userUid,
    required String userImage,
    required String fullName,
    required String userAction,
  }) async {
    final notificationData = UserModel(
      userId: userUid,
      userImage: userImage,
      userName: fullName,
    );

    await _repository.insertNotification(notificationData: notificationData);
  }

  Future<PostDetailModel> executeGetPostData({
    required String userId,
    required String postId,
  }) async {
    final postData = await _repository.getPostData(
      postId: postId,
      userId: userId,
    );

    if (!postData.postDoc.exists || !postData.userDoc.exists) {
      throw Exception('Post or user not found');
    }

    final userAccount = await _getAccountMap(userDoc: postData.userDoc);

    final likesCount = await _repository.getPostLikesCount(postId: postId);

    final comments = await _repository.getCommentsWithUsers(
      commentsDocs: postData.commentsDocs,
      postId: postId,
    );

    final postDocData = postData.postDoc.data() as Map<String, dynamic>;
    final post = PostModel.fromFirestoreToPost({
      ...userAccount,
      ...postDocData,
      'likesNumber': likesCount,
      'commentsNumber': comments.length,
    });

    return PostDetailModel(postModel: post, commentsList: comments);
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
}