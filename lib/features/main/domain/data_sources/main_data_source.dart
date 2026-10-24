import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class MainDataSource implements FirestoreService {
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications();

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream();

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptCurrent({
    required String uId,
  });
}