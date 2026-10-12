import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/setup_friends/domain/repositories/setup_friends_repository.dart';


class FirestoreSetupFriendsRepository implements SetupFriendsRepository {
  final SessionService _sessionService;
  final FirestoreBaseService _repository;

  FirestoreSetupFriendsRepository({
    required SessionService sessionService,
    required FirestoreBaseService repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  @override
  Future<List<MyModel>> getSuggestsUsers() async {
    final allUsers = await _getAllUsersFromFirebase();

    final usersData = await _fetchAccountsData(
        allUsers, _sessionService.currentUid);
    return _filterNullValues(usersData);
  }

  Future<QuerySnapshot> _getAllUsersFromFirebase() async {
    return await _repository.getSupCollection(collectionPath: 'users');
  }

  Future<List<MyModel?>> _fetchAccountsData(QuerySnapshot users,
      String currentUserId) async {
    final futures = users.docs.map((doc) async {
      if (doc.id == currentUserId) return null;

      final account = await _repository.getDoc(
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
      _repository.setSubDoc(
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          subDocId: friendId,
          supDocId: _sessionService.currentUid,
          data: {'uId': friendId}
      ),
      _repository.setSubDoc(
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          supDocId: friendId,
          subDocId: _sessionService.currentUid,
          data: {'uId': _sessionService.currentUid}
      )
    ]);
  }
}