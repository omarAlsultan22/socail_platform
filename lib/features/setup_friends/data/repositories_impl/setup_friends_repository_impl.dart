import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';
import 'package:social_app/features/setup_friends/domain/repositories/setup_friends_repository.dart';


class SetupFriendsRepositoryImpl implements SetupFriendsRepository {
  final FirestoreService _dataSource;
  final SessionService _sessionService;

  SetupFriendsRepositoryImpl({
    required FirestoreService dataSource,
    required SessionService sessionService
  })
      : _dataSource = dataSource,
        _sessionService = sessionService;

  @override
  Future<List<MyModel>> getSuggestsUsers() async {
    final allUsers = await _getAllUsersFromFirebase();

    final usersData = await _fetchAccountsData(
        allUsers, _sessionService.currentUid);
    return _filterNullValues(usersData);
  }

  Future<QuerySnapshot> _getAllUsersFromFirebase() async {
    return await _dataSource.getSupCollection(collectionPath: 'users');
  }

  Future<List<MyModel?>> _fetchAccountsData(QuerySnapshot users,
      String currentUserId) async {
    final futures = users.docs.map((doc) async {
      if (doc.id == currentUserId) return null;

      final account = await _dataSource.getDoc(
          collectionPath: 'accounts', docId: doc.id);

      if (!account.exists) return null;

      return MyModel.fromJson(account.data() as Map<String, dynamic>);
    }).toList();

    return await Future.wait(futures);
  }

  List<MyModel> _filterNullValues(List<MyModel?> data) {
    return data.where((user) => user != null).cast<MyModel>().toList();
  }

  @override
  Future<void> confirmNewFriend({
    required String friendId,
  }) async {
    await Future.wait([
      _dataSource.setSubDoc(
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          subDocId: friendId,
          supDocId: _sessionService.currentUid,
          data: {'uId': friendId}
      ),
      _dataSource.setSubDoc(
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          supDocId: friendId,
          subDocId: _sessionService.currentUid,
          data: {'uId': _sessionService.currentUid}
      )
    ]);
  }
}