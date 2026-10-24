import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/repositories/friendship_repository.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


class FriendshipRepositoryImpl implements FriendshipRepository {
  final FirestoreService _dataSource;
  FriendshipRepositoryImpl({
    required FirestoreService dataSource
  }): _dataSource = dataSource;

  @override
  Future<void> addFriendRequestToFirestore({
    required String userId,
    required MyModel friendInfo,
  }) async {
    await _dataSource.setSubDoc(
      supDocId: userId,
      data: friendInfo.toJson(),
      subDocId: friendInfo.myId,
      supCollectionPath: AppStrings.users,
      subCollectionPath: AppStrings.requests,
    );
  }

  @override
  Future<void> confirmFriendInFirestore({
    required String currentUserId,
    required String friendId,
  }) async {
    await Future.wait([
      _dataSource.setSubDoc(
        subDocId: friendId,
        supDocId: currentUserId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends,
        data: {AppStrings.uId: friendId}
      ),
      _dataSource.setSubDoc(
          supDocId: friendId,
          subDocId: currentUserId,
          supCollectionPath: AppStrings.users,
          subCollectionPath: AppStrings.friends,
          data: {AppStrings.uId: currentUserId}
      )
    ]);
  }

  @override
  Stream<List<MyModel>> getConversationsStream({
    required String userId,
    required Future<MyModel> Function(String id) getUserModelData,
  }) {
    return _dataSource.getSubCollectionStream(
        docId: userId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.requests)
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
    await _dataSource.deleteSubDoc(
        supDoc: currentUserId,
        subDoc: friendId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.requests
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
      _dataSource.getSupCollection(collectionPath: AppStrings.users),
      _dataSource.getSubCollection(
          docId: currentUserId,
          supCollectionPath: AppStrings.users,
          subCollectionPath: AppStrings.friends
      ),
      _dataSource.getSubCollection(
          docId: currentUserId,
          supCollectionPath: AppStrings.users,
          subCollectionPath: AppStrings.requests
      ),
    ]);
    return (
    allUsers: result[0],
    friends: result[1],
    requests: result[2]
    );
  }
}