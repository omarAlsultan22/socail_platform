import 'package:flutter/cupertino.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/data_sources/comments_likes_data_source.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/services/domain/i_user_account_service.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class CommentsLikesDataSourceImpl extends FirestoreServiceImpl implements CommentsLikesDataSource {
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  CommentsLikesDataSourceImpl({
    required SessionService sessionService,
    required IUserAccountService userAccountService
  })
      : _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  }) async* {
    final friendsSnapshot = await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );
    await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );

    final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toSet();

    final docRef = firestore
        .collection(AppStrings.posts)
        .doc(postId)
        .collection(AppStrings.commentsList)
        .doc(commentId)
        .collection(AppStrings.commentsLikes);

    await for (final commentLikesSnapshot in docRef.snapshots()) {
      if (commentLikesSnapshot.docs.isEmpty) {
        yield [];
        continue;
      }

      final List<MyModel> validUsers = [];

      for (final commentLike in commentLikesSnapshot.docs) {
        try {
          final userId = commentLike.id;
          final accountDoc = await getDoc(
              docId: userId, collectionPath: AppStrings.accounts);
          if (!accountDoc.exists) continue;

          final accountData = accountDoc.data() as Map<String, dynamic>;
          accountData['isFriend'] = friendsList.contains(userId);

          final userAccount = await _userAccountService.getUserAccount(
              userAccount: accountData);
          validUsers.add(MyModel.fromJson(userAccount));
        } catch (e) {
          debugPrint(
              'Error processing comment like from user ${commentLike.id}: $e');
          rethrow;
        }
      }
      yield validUsers;
    }
  }
}