import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/friendship/domain/repositories/friendship_repository.dart';


class FakeFriendshipRepository implements FriendshipRepository {
  // ===== addFriendRequestToFirestore =====
  int addFriendRequestCallCount = 0;
  String? lastAddUserId;
  MyModel? lastAddFriendInfo;

  @override
  Future<void> addFriendRequestToFirestore({
    required String userId,
    required MyModel friendInfo,
  }) async {
    addFriendRequestCallCount++;
    lastAddUserId = userId;
    lastAddFriendInfo = friendInfo;
  }

  // ===== confirmFriendInFirestore =====
  int confirmFriendCallCount = 0;
  String? lastConfirmCurrentUserId;
  String? lastConfirmFriendId;

  @override
  Future<void> confirmFriendInFirestore({
    required String currentUserId,
    required String friendId,
  }) async {
    confirmFriendCallCount++;
    lastConfirmCurrentUserId = currentUserId;
    lastConfirmFriendId = friendId;
  }

  // ===== getConversationsStream =====
  Stream<List<MyModel>>? conversationsStream;
  int getConversationsStreamCallCount = 0;
  String? lastUserId;
  Future<MyModel> Function(String id)? lastGetUserModelData;

  @override
  Stream<List<MyModel>> getConversationsStream({
    required String userId,
    required Future<MyModel> Function(String id) getUserModelData,
  }) {
    getConversationsStreamCallCount++;
    lastUserId = userId;
    lastGetUserModelData = getUserModelData;
    return conversationsStream!;
  }

  // ===== declineFriendRequestInFirestore =====
  int declineFriendCallCount = 0;
  String? lastDeclineCurrentUserId;
  String? lastDeclineFriendId;

  @override
  Future<void> declineFriendRequestInFirestore({
    required String currentUserId,
    required String friendId,
  }) async {
    declineFriendCallCount++;
    lastDeclineCurrentUserId = currentUserId;
    lastDeclineFriendId = friendId;
  }

  // ===== getFriendsSuggestData =====
  ({
  QuerySnapshot allUsers,
  QuerySnapshot friends,
  QuerySnapshot requests
  })? getFriendsSuggestDataResult;
  int getFriendsSuggestDataCallCount = 0;

  @override
  Future<({
  QuerySnapshot allUsers,
  QuerySnapshot friends,
  QuerySnapshot requests
  })> getFriendsSuggestData({
    required String currentUserId,
  }) async {
    getFriendsSuggestDataCallCount++;
    return getFriendsSuggestDataResult!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeFriendshipRepository.${invocation.memberName} not stubbed',
      );
}