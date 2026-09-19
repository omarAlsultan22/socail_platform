import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../domain/repositories/post_detail_repository.dart';
import '../data_sources/remote/firestore_post_detail_service.dart';


class FirestorePostDetailRepository implements PostDetailRepository {
  final FirestorePostDetailService _repository;

  FirestorePostDetailRepository({
    required FirestorePostDetailService repository
  })
      : _repository = repository;

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
}