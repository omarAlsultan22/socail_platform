import 'package:flutter/cupertino.dart';
import '../../domain/data_sources/likes_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/services/domain/i_user_account_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class LikesDataSourceImpl extends FirestoreServiceImpl implements LikesDataSource {
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  LikesDataSourceImpl({
    required SessionService sessionService,
    required IUserAccountService userAccountService
  })
      : _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  Stream<List<MyModel>> getLikesStream(String postId) async* {
    final friendsSnapshot = await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );

    final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toList();

    await for (final likesSnapshot
    in getSubCollectionStream(docId: postId,
        supCollectionPath: AppStrings.posts,
        subCollectionPath: AppStrings.likesList)) {
      if (likesSnapshot.docs.isEmpty) {
        yield [];
        continue;
      }

      final List<MyModel> validUsers = [];
      for (final like in likesSnapshot.docs) {
        try {
          final userId = like.id;
          final accountDoc = await getDoc(
              docId: userId, collectionPath: AppStrings.accounts);
          if (!accountDoc.exists) continue;

          final accountData = accountDoc.data() as Map<String, dynamic>;
          accountData['isFriend'] = friendsList.contains(userId);

          final userAccount = await _userAccountService.getUserAccount(
              userAccount: accountData);
          validUsers.add(MyModel.fromJson(userAccount));
        } catch (e) {
          debugPrint('Error processing like from user ${like.id}: $e');
          rethrow;
        }
      }

      validUsers.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
      yield validUsers;
    }
  }
}