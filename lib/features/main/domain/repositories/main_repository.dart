import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class FirestoreMainRepository {

  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId});

  List<UserModel> convertUsersToModels(QuerySnapshot snapshot);

  Future<QuerySnapshot> getFriendsList({required String uId});

  Future<QuerySnapshot> getUnreadNotifications();

  Stream<QuerySnapshot> getNotificationsStream();

  Future<QuerySnapshot> getFriendRequests();

  Future<QuerySnapshot> getAllMessages();

  Stream<QuerySnapshot> getFriendRequestsStream();

  Future<QuerySnapshot> getUnreadConversations(String messageDocId);

  Stream<QuerySnapshot> getUnreadConversationsStream(String messageDocId);
}