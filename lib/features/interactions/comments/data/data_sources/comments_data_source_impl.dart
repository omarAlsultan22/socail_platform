import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../domain/data_sources/comments_data_source.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/services/domain/i_user_account_service.dart';
import 'package:social_app/core/presentation/mixins/base_like_mixin_impl.dart';
import '../../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class CommentsDataSourceImpl extends FirestoreServiceImpl with BaseLikeMixinImpl implements CommentsDataSource{
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  CommentsDataSourceImpl({
    required SessionService sessionService,
    required IUserAccountService userAccountService
  })
      : _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  String get likeCollectionPath => 'commentsLikes';

  @override
  FirestoreService get dataSource => this;

  @override
  SessionService get sessionService => _sessionService;

  CollectionReference<Map<String, dynamic>> _commentsRef(String postId) =>
      firestore.collection('posts').doc(postId).collection('commentsList');

  @override
  Stream<List<CommentModel>> getCommentsStream(String postId) async* {
    final commentsRef = _commentsRef(postId);

    await for (final snapshot in commentsRef.snapshots()) {
      if (snapshot.docs.isEmpty) {
        yield [];
        continue;
      }

      final List<CommentModel> validComments = [];

      for (final comment in snapshot.docs) {
        try {
          final commentFields = comment.data();
          final userId = commentFields['userId'] as String?;
          final commentId = comment.id;

          if (userId == null) continue;

    final likesCount = await getCount(
              collectionPath: 'commentsLikes',
              docRef: commentsRef.doc(commentId)
          );
          final hasMeLiked_ = await hasMeLiked(comment.id);

          final accountDoc = await getDoc(
              docId: userId, collectionPath: 'accounts');
          if (!accountDoc.exists) continue;

          final userAccount = await _userAccountService.getAccountMap(
              userDoc: accountDoc);

          validComments.add(
            CommentModel.fromJson({
              ...userAccount,
              ...commentFields,
              'docUid': commentId,
              'hasMeLiked': hasMeLiked_,
              'likesNumber': likesCount.count,
            }),
          );
        } catch (e) {
          print('Error processing comment ${comment.id}: $e');
        }
      }

      validComments.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
      yield validComments;
    }
  }

  @override
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    final accountDoc = await getDoc(
        docId: _sessionService.currentUid, collectionPath: 'accounts');
    if (!accountDoc.exists) return;

    final docRef = _commentsRef(postId).doc();
    final docId = docRef.id;

    final userAccount = await _userAccountService.getAccountMap(
        userDoc: accountDoc);

    final actionModel = CommentModel.fromJson({
      ...userAccount,
      'postId': postId,
      'docUid': docId,
      'userAction': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await docRef.set(actionModel.toJson());
  }

  @override
  Future<void> removeComment({
    required String postId,
    required String commentId,
  }) async {
    await _commentsRef(postId).doc(commentId).delete();
  }

  @override
  Future<void> addCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) async {
    final commentRef = _commentsRef(postId).doc(commentId);

    if (commentOwnerId == _sessionService.currentUid) {
      await commentRef.update({'isActive': true});
    }

    final likeRef = commentRef.collection('commentsLikes').doc(
        _sessionService.currentUid);

    final userModel = MyModel(
      myDateTime: DateTime.now(),
      myId: _sessionService.currentUid,
    );

    await likeRef.set(userModel.toJson());
  }

  @override
  Future<void> deleteCommentLike({
    required String postId,
    required String commentId,
    required String commentOwnerId,
  }) async {
    final commentRef = _commentsRef(postId).doc(commentId);

    if (commentOwnerId == _sessionService.currentUid) {
      await commentRef.update({'isActive': false});
    }

    await commentRef.collection('commentsLikes')
        .doc(_sessionService.currentUid)
        .delete();
  }
}