import 'package:social_app/features/friend_interactions/domain/repositories/friend_interactions_repository.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseFriendInteractionsRepository implements FriendInteractionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addFriendRequestToFirestore({
    required String userId,
    required UserModel friendInfo,
  }) async {
    await _firestore.collection('users').doc(userId)
        .collection('requests').doc(friendInfo.userId)
        .set(friendInfo.toJson());
  }

  @override
  Future<void> confirmFriendInFirestore({
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

  @override
  Stream<List<UserModel>> getConversationsStream({
    required String userId,
    required Future<UserModel> Function(String id) getUserModelData,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('requests')
        .snapshots()
        .asyncMap((querySnapshot) async {
      final userModels = await Future.wait(
        querySnapshot.docs.map((friendDoc) async {
          return await getUserModelData(friendDoc.id);
        }),
      );
      return userModels;
    });
  }

  @override
  Future<void> declineFriendRequestInFirestore({
    required String currentUserId,
    required String friendId,
  }) async {
    await _firestore.collection('users').doc(currentUserId)
        .collection('requests').doc(friendId).delete();
  }

  @override
  Future<({
  QuerySnapshot allUsers,
  QuerySnapshot friends,
  QuerySnapshot requests
  })> getFriendsSuggestData({
    required String currentUserId,
  }) async {
    final result = await Future.wait([
      _firestore.collection('users').get(),
      _firestore.collection('users').doc(currentUserId)
          .collection('friends').get(),
      _firestore.collection('users').doc(currentUserId)
          .collection('requests').get()
    ]);
    return (
    allUsers: result[0],
    friends: result[1],
    requests: result[2]
    );
  }

  @override
  Future<void> deleteRequestFromFirestore({
    required String currentUserId,
    required String docId,
  }) async {
    await _firestore.collection('users').doc(currentUserId)
        .collection('requests').doc(docId).delete();
  }
}