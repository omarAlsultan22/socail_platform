import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/user_model.dart';


abstract class FriendshipRepository {

  Future<void> addFriendRequestToFirestore({
    required String userId,
    required UserModel friendInfo,
  });

  Future<void> confirmFriendInFirestore({
    required String currentUserId,
    required String friendId,
  });

  Stream<List<UserModel>> getConversationsStream({
    required String userId,
    required Future<UserModel> Function(String id) getUserModelData,
  });

  Future<void> declineFriendRequestInFirestore({
    required String currentUserId,
    required String friendId,
  });

  Future<({
  QuerySnapshot allUsers,
  QuerySnapshot friends,
  QuerySnapshot requests
  })> getFriendsSuggestData({
    required String currentUserId,
  });
}