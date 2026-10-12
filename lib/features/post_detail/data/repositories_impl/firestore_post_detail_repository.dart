import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../domain/repositories/post_detail_repository.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../../../core/presentation/mixins/base_like_mixin.dart';
import '../data_sources/remote/firestore_post_detail_service.dart';


class FirestorePostDetailRepository with BaseLikeMixin implements PostDetailRepository {
  final SessionService _sessionService;
  final FirestorePostDetailService _repository;

  FirestorePostDetailRepository({
    required SessionService sessionService,
    required FirestorePostDetailService repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => throw UnimplementedError();

  @override
  FirestorePostDetailService get repository => _repository;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    return await repository.getPostData(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<int?> getPostLikes({required String postId}) async {
    {
      final postRef = repository.getDocRef(
          docId: postId,
          collectionPath: 'posts'
      );
      final likesCount = await repository.getCount(
          docRef: postRef, collectionPath: 'likesList');
      return likesCount.count;
    }
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await repository.getCommentsWithLikes(
      postId: postId,
      commentsDocs: commentsDocs,
    );

    final comments = await Future.wait(
      commentsWithLikes.map((doc) async {
        final commentData = doc.data();
        final commentUserDoc = await repository.getDoc(
            docId: commentData['userId'], collectionPath: 'accounts'
        );

        if (!commentUserDoc.exists) return null;

        final userAccount = await repository.getAccountMap(
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
    await repository.setSupDoc(
      isMerge: false,
      docId: notificationData.myId,
      data: notificationData.toJson(),
      collectionPath: 'notifications',
    );
  }
}