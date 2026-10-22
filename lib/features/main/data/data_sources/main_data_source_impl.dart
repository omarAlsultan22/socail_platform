import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/main/domain/data_sources/main_data_source.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class MainDataSourceImpl extends FirestoreServiceImpl implements MainDataSource{

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptCurrent({
    required String uId,
  }) async {
    return await firestore
        .collection('users')
        .where('userId', isNotEqualTo: uId)
        .get()
        .timeout(duration);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications() async {
    return await firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get()
        .timeout(duration);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream() {
    return firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .timeout(duration);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadConversations({
    required String messageDocId,
  }) async {
    return await firestore
        .collection('messages')
        .doc(messageDocId)
        .collection('conversations')
        .where('unreadMessage', isEqualTo: true)
        .get()
        .timeout(duration);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadConversationsStream({
    required String messageDocId,
  }) {
    return firestore
        .collection('messages')
        .doc(messageDocId)
        .collection('conversations')
        .where('unreadMessage', isEqualTo: true)
        .snapshots()
        .timeout(duration);
  }
}