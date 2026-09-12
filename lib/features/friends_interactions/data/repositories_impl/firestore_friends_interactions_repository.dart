import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../../domain/repositories/friends_interactions_repository.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirebaseFriendsInteractionsRepository implements FriendsInteractionsRepository {
  final FirestoreBaseService _repository;
  FirebaseFriendsInteractionsRepository({
    required FirestoreBaseService repository
  }): _repository = repository;

  @override
  Future<void> addFriendRequestToFirestore({
    required String userId,
    required UserModel friendInfo,
  }) async {
    await _repository.setSubDoc(
      supDocId: userId,
      data: friendInfo.toJson(),
      subDocId: friendInfo.userId,
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
    );
  }

  @override
  Future<void> confirmFriendInFirestore({
    required String currentUserId,
    required String friendId,
  }) async {
    await Future.wait([
      _repository.setSubDoc(
        subDocId: friendId,
        supDocId: currentUserId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        data: {'uId': friendId}
      ),
      _repository.setSubDoc(
          supDocId: friendId,
          subDocId: currentUserId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          data: {'uId': currentUserId}
      )
    ]);
  }

  @override
  Stream<List<UserModel>> getConversationsStream({
    required String userId,
    required Future<UserModel> Function(String id) getUserModelData,
  }) {
    return _repository.getSubCollectionStream(
        docId: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'requests')
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
    await _repository.deleteSubDoc(
        supDoc: currentUserId,
        subDoc: friendId,
        supCollectionPath: 'users',
        subCollectionPath: 'requests'
    );
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
      _repository.getSupCollection(collectionPath: 'users'),
      _repository.getSubCollection(
          docId: currentUserId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends'
      ),
      _repository.getSubCollection(
          docId: currentUserId,
          supCollectionPath: 'users',
          subCollectionPath: 'requests'
      ),
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
    await _repository.deleteSubDoc(
        supDoc: currentUserId,
        subDoc: docId,
        supCollectionPath: 'users',
        subCollectionPath: 'requests'
    );
  }
}