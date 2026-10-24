import 'dart:async';
import '../repositories/main_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';


class MainUseCases {
  final MainRepository _repository;

  MainUseCases({required MainRepository repository})
      : _repository = repository;

  Future<List<MyModel>> executeCheckOnAnyFriends(
      {required String uId}) async {
    final friendsSnapshot = await _repository.getFriendsList(uId: uId);

    if (friendsSnapshot.docs.isNotEmpty) {
      return [];
    }

    final usersSnapshot = await _repository.getAllUsersExceptCurrent(uId: uId);
    return _repository.convertUsersToModels(usersSnapshot);
  }

  Future<({
  int count,
  Set<String> docIds,
  })> executeGetInitialNotificationsCount() async {
    final snapshot = await _repository.getUnreadNotifications();
    return (
    count: snapshot.size,
    docIds: snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }

  Stream<({
  int count,
  Set<String> docIds,
  List<QueryDocumentSnapshot> docs,
  })> executeGetNotificationsStream() {
    return _repository.getNotificationsStream().map((snapshot) {
      return (
      count: snapshot.size,
      docIds: snapshot.docs.map((doc) => doc.id).toSet(),
      docs: snapshot.docs,
      );
    });
  }

  Future<({
  int count,
  Set<String> docIds,
  })> executeGetInitialFriendRequestsCount() async {
    final snapshot = await _repository.getFriendRequests();
    return (
    count: snapshot.size,
    docIds: snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }

  Stream<({
  int count,
  Set<String> docIds,
  })> executeGetFriendRequestsStream() {
    return _repository.getFriendRequestsStream().map((snapshot) {
      return (
      count: snapshot.size,
      docIds: snapshot.docs.map((doc) => doc.id).toSet(),
      );
    });
  }
}