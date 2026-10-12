import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


abstract class SharesRemoteDataSource extends FirestoreBaseService{
  Stream<List<MyModel>> getSharesStream(String postId);
}


class SharesRemoteDataSourceImpl extends SharesRemoteDataSource {
  final SessionService _sessionService;
  final UserAccountService _userAccountService;

  SharesRemoteDataSourceImpl({
    required SessionService sessionService,
    required UserAccountService userAccountService
  })
      : _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  Stream<List<MyModel>> getSharesStream(String postId) async* {
    final friendsSnapshot = await getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );

    final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toList();
    await for (final sharesSnapshot in getSubCollectionStream(docId: postId,
        supCollectionPath: 'posts',
        subCollectionPath: 'sharesList')) {
      if (sharesSnapshot.docs.isEmpty) {
        yield [];
        continue;
      }

      final List<MyModel> validUsers = [];
      for (final share in sharesSnapshot.docs) {
        try {
          final userId = share.id;
          final accountDoc = await getDoc(
              docId: userId, collectionPath: 'accounts');
          if (!accountDoc.exists) continue;

          final accountData = accountDoc.data() as Map<String, dynamic>;
          accountData['isFriend'] = friendsList.contains(userId);

          final userAccount = await _userAccountService.getUserAccount(
              userAccount: accountData);
          validUsers.add(MyModel.fromJson(userAccount));
        } catch (e) {
          print('Error processing share from user ${share.id}: $e');
        }
      }

      validUsers.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
      yield validUsers;
    }
  }
}