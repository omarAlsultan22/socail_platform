import '../../data/models/post_detail_model.dart';
import '../repositories/post_detail_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/data/session_service.dart';


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
    final notificationData = MyModel(
      myId: userUid,
      myName: fullName,
      myImageUrl: userImage
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

    final hasMeLiked = await _repository.hasMeLiked(postId);
    final likesCount = await _repository.getPostLikes(postId: postId);


    final comments = await _repository.getCommentsWithUsers(
      commentsDocs: postData.commentsDocs,
      postId: postId,
    );

    final postDocData = postData.postDoc.data() as Map<String, dynamic>;
    final post = PostModel.fromFirestoreToPost({
      ...userAccount,
      ...postDocData,
      AppStrings.hasMeLiked: hasMeLiked,
      AppStrings.likesNumber: likesCount,
      AppStrings.commentsNumber: comments.length,
    });

    return PostDetailModel(postModel: post, commentsList: comments);
  }

  Future<Map<String, dynamic>> _getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    return {
      AppStrings.userImage: userData[AppStrings.userImage] ?? AppStrings.empty,
      AppStrings.userName: userData[AppStrings.userName] ?? AppStrings.empty,
      AppStrings.userId: userDoc.id,
    };
  }
}