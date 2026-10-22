import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../domain/repositories/post_detail_repository.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../domain/data_sources/post_detail_data_source.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin_impl.dart';


class PostDetailRepositoryImpl with BaseLikeMixinImpl implements PostDetailRepository {
  final SessionService _sessionService;
  final PostDetailDataSource _dataSource;

  PostDetailRepositoryImpl({
    required SessionService sessionService,
    required PostDetailDataSource dataSource
  })
      : _dataSource = dataSource,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => 'likesList';

  @override
  PostDetailDataSource get dataSource => _dataSource;

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
    return await dataSource.getPostData(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<int?> getPostLikes({required String postId}) async {
    {
      final postRef = dataSource.getDocRef(
          docId: postId,
          collectionPath: 'posts'
      );
      final likesCount = await dataSource.getCount(
          docRef: postRef, collectionPath: 'likesList');
      return likesCount.count;
    }
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await dataSource.getCommentsWithLikes(
      postId: postId,
      commentsDocs: commentsDocs,
    );

    final comments = await Future.wait(
      commentsWithLikes.map((doc) async {
        final commentData = doc.data();
        final commentUserDoc = await dataSource.getDoc(
            docId: commentData['userId'], collectionPath: 'accounts'
        );

        if (!commentUserDoc.exists) return null;

        final userAccount = await dataSource.getAccountMap(
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
    await dataSource.setSupDoc(
      isMerge: false,
      docId: notificationData.myId,
      data: notificationData.toJson(),
      collectionPath: 'notifications',
    );
  }
}