import 'package:social_app/core/data/models/user_model.dart';
import '../../../../core/constants/user_details.dart';
import '../../data/converters/friends_info_converter.dart';
import '../repositories/friend_interactions_repository.dart';


class FriendInteractionsUseCase {
  final FriendInteractionsRepository _repository;

  FriendInteractionsUseCase({required FriendInteractionsRepository repository})
      : _repository = repository;

  Future<String> executeAddFriendRequest({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty');
    }

    UserModel friendInfo = UserModel(
        userId: UserDetails.uId,
        dateTime: DateTime.now()
    );

    await _repository.addFriendRequestToFirestore(
      userId: userId,
      friendInfo: friendInfo,
    );

    return userId;
  }

  Future<String> executeConfirmNewFriend({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty');
    }

    await _repository.confirmFriendInFirestore(
      currentUserId: UserDetails.uId,
      friendId: userId,
    );

    return userId;
  }

  // ✅ لا تغيير - هذا Stream
  Stream<List<UserModel>> executeGetConversationsStream({
    required String userId,
    required Future<UserModel> Function(String id) getUserModelData,
  }) {
    return _repository.getConversationsStream(
      userId: userId,
      getUserModelData: getUserModelData,
    );
  }

  // ✅ تعديل: تعيد uId فقط
  Future<String> executeDeclineFriendRequest({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty');
    }

    await _repository.declineFriendRequestInFirestore(
      currentUserId: UserDetails.uId,
      friendId: userId,
    );

    return userId;
  }

  // ✅ لا تغيير - هذا صحيح
  Future<List<UserModel>> executeGetFriendsSuggests() async {
    final data = await _repository.getFriendsSuggestData(
      currentUserId: UserDetails.uId,
    );

    FriendsInfoConverter friendsInfo = await FriendsInfoConverter
        .fromQuerySnapshotSuggests(
      data.requests,
      data.friends,
      data.allUsers,
    );

    return friendsInfo.data;
  }

  Future<void> executeUpdateFriendRequestsCount({
    required String docId,
  }) async {
    await _repository.deleteRequestFromFirestore(
      currentUserId: UserDetails.uId,
      docId: docId,
    );
  }
}