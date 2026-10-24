import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';


abstract class MainRepository {

  Future<QuerySnapshot> getFriendRequests();

  Future<QuerySnapshot> getUnreadNotifications();

  Stream<QuerySnapshot> getNotificationsStream();

  Stream<QuerySnapshot> getFriendRequestsStream();

  List<MyModel> convertUsersToModels(QuerySnapshot snapshot);

  Future<QuerySnapshot> getFriendsList({required String uId});

  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId});
}