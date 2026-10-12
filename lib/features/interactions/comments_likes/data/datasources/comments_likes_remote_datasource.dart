import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


abstract class CommentsLikesRemoteDataSource extends FirestoreBaseService{
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  });
}

class CommentsLikesRemoteDataSourceImpl extends CommentsLikesRemoteDataSource {
  final SessionService _sessionService;
  final UserAccountService _userAccountService;

  CommentsLikesRemoteDataSourceImpl({
    required SessionService sessionService,
    required UserAccountService userAccountService
  }) : _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  }) async* {
    final friendsSnapshot = await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );

    final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toSet();

    final docRef = firestore
        .collection('posts')
        .doc(postId)
        .collection('commentsList')
        .doc(commentId)
        .collection('commentsLikes');

    await for (final commentLikesSnapshot in docRef.snapshots()) {
      if (commentLikesSnapshot.docs.isEmpty) {
        yield [];
        continue;
      }

      final List<MyModel> validUsers = [];

      for (final commentLike in commentLikesSnapshot.docs) {
        try {
          final userId = commentLike.id;
          final accountDoc = await getDoc(docId: userId, collectionPath: 'accounts');
          if (!accountDoc.exists) continue;

          final accountData = accountDoc.data() as Map<String, dynamic>;
          accountData['isFriend'] = friendsList.contains(userId);

          final userAccount = await _userAccountService.getUserAccount(userAccount: accountData);
          validUsers.add(MyModel.fromJson(userAccount));
        } catch (e) {
          print('Error processing comment like from user ${commentLike.id}: $e');
        }
      }

      yield validUsers;
    }
  }
}