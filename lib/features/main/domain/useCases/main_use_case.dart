import 'dart:async';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/main/data/repositories_impl/firestore_main_repository.dart';


class MainUseCases {
  final FirestoreMainRepository _repository;

  MainUseCases({required FirestoreMainRepository repository})
      : _repository = repository;

  Future<List<UserModel>> executeCheckOnAnyFriends(
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

  Future<({
  int count,
  Set<String> docIds,
  List<StreamSubscription> subscriptions,
  })> executeGetInitialMessagesCount() async {
    final messagesQuery = await _repository.getAllMessages();
    int totalCount = 0;
    final Set<String> allDocIds = {};
    final List<StreamSubscription> subscriptions = [];

    for (final doc in messagesQuery.docs) {
      final snapshot = await _repository.getUnreadConversations(doc.id);
      totalCount += snapshot.size;
      allDocIds.addAll(snapshot.docs.map((d) => d.id));
    }

    return (
    count: totalCount,
    docIds: allDocIds,
    subscriptions: subscriptions,
    );
  }

  Stream<({
  int count,
  Set<String> docIds,
  })> executeGetMessagesStreamForDoc(String docId, int currentCount,
      Set<String> currentDocIds) {
    return _repository.getUnreadConversationsStream(docId).map((snapshot) {
      final newDocIds = snapshot.docs.map((d) => d.id).toSet();
      int unreadMessages = 0;

      for (var doc in snapshot.docs) {
        if (doc['unreadMessage'] == true) {
          unreadMessages++;
        }
      }

      final newCount = currentCount + unreadMessages -
          (currentDocIds.length - newDocIds.length);

      return (
      count: newCount,
      docIds: newDocIds,
      );
    });
  }
}