import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import 'package:social_app/features/setup_friends/domain/repositories/setup_friends_repository.dart';


class FirestoreSetupFriendsRepository implements SetupFriendsRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getSuggestsUsers() async {
    final allUsers = await _getAllUsersFromFirebase();
    final currentUserId = UserDetails.uId;

    final usersData = await _fetchAccountsData(allUsers, currentUserId);
    return _filterNullValues(usersData);
  }

  Future<QuerySnapshot> _getAllUsersFromFirebase() async {
    return await _firestore.collection('users').get();
  }

  Future<List<UserModel?>> _fetchAccountsData(
      QuerySnapshot users,
      String currentUserId
      ) async {
    final futures = users.docs.map((doc) async {
      if (doc.id == currentUserId) return null;

      final account = await _firestore.collection('accounts')
          .doc(doc.id)
          .get();

      if (!account.exists) return null;

      return UserModel.fromJson(account.data() as Map<String, dynamic>);
    }).toList();

    return await Future.wait(futures);
  }

  List<UserModel> _filterNullValues(List<UserModel?> data) {
    return data.where((user) => user != null).cast<UserModel>().toList();
  }

  @override
  Future<void> confirmNewFriend({
    required String currentUserId,
    required String friendId,
  }) async {
    await Future.wait([
      _firestore.collection('users').doc(currentUserId)
          .collection('friends').doc(friendId).set({'uId': friendId}),
      _firestore.collection('users').doc(friendId)
          .collection('friends').doc(currentUserId).set({'uId': currentUserId})
    ]);
  }
}