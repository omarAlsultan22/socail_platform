import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreMainService extends FirestoreBaseService{
  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptCurrent({
    required String uId,
  }) async {
    return await firestore
        .collection('users')
        .where('userId', isNotEqualTo: uId)
        .get()
        .timeout(duration);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications() async {
    return await firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get()
        .timeout(duration);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream() {
    return firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .timeout(duration);
  }

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