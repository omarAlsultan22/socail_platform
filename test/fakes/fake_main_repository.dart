import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/main/domain/repositories/main_repository.dart';


class FakeMainRepository implements MainRepository {
  // ===== getFriendsList =====
  QuerySnapshot? friendsListResult;
  int getFriendsListCallCount = 0;

  @override
  Future<QuerySnapshot> getFriendsList({required String uId}) async {
    getFriendsListCallCount++;
    return friendsListResult!;
  }

  // ===== getAllUsersExceptCurrent =====
  QuerySnapshot? allUsersExceptCurrentResult;
  int getAllUsersExceptCurrentCallCount = 0;

  @override
  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId}) async {
    getAllUsersExceptCurrentCallCount++;
    return allUsersExceptCurrentResult!;
  }

  // ===== convertUsersToModels =====
  List<MyModel> convertUsersToModelsResult = [];
  int convertUsersToModelsCallCount = 0;

  @override
  List<MyModel> convertUsersToModels(QuerySnapshot snapshot) {
    convertUsersToModelsCallCount++;
    return convertUsersToModelsResult;
  }

  // ===== getUnreadNotifications =====
  QuerySnapshot? unreadNotificationsResult;
  int getUnreadNotificationsCallCount = 0;

  @override
  Future<QuerySnapshot> getUnreadNotifications() async {
    getUnreadNotificationsCallCount++;
    return unreadNotificationsResult!;
  }

  // ===== getNotificationsStream =====
  Stream<QuerySnapshot>? notificationsStream;
  int getNotificationsStreamCallCount = 0;

  @override
  Stream<QuerySnapshot> getNotificationsStream() {
    getNotificationsStreamCallCount++;
    return notificationsStream!;
  }

  // ===== getFriendRequests =====
  QuerySnapshot? friendRequestsResult;
  int getFriendRequestsCallCount = 0;

  @override
  Future<QuerySnapshot> getFriendRequests() async {
    getFriendRequestsCallCount++;
    return friendRequestsResult!;
  }

  // ===== getFriendRequestsStream =====
  Stream<QuerySnapshot>? friendRequestsStream;
  int getFriendRequestsStreamCallCount = 0;

  @override
  Stream<QuerySnapshot> getFriendRequestsStream() {
    getFriendRequestsStreamCallCount++;
    return friendRequestsStream!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeMainRepository.${invocation.memberName} not stubbed',
      );
}