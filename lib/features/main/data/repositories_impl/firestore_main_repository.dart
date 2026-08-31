import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';


class FirestoreMainRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب قائمة الأصدقاء
  Future<QuerySnapshot> getFriendsList({required String uId}) async {
    return await _firestore
        .collection('users')
        .doc(uId)
        .collection('friends')
        .get();
  }

  // جلب قائمة المستخدمين (باستثناء المستخدم الحالي)
  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId}) async {
    return await _firestore
        .collection('users')
        .where('userId', isNotEqualTo: uId)
        .get();
  }

  // تحويل المستخدمين إلى Models
  List<UserModel> convertUsersToModels(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // جلب إشعارات غير مقروءة
  Future<QuerySnapshot> getUnreadNotifications() async {
    return await _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
  }

  // Stream للإشعارات
  Stream<QuerySnapshot> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  // جلب طلبات الأصدقاء
  Future<QuerySnapshot> getFriendRequests() async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('requests')
        .get();
  }

  // Stream لطلبات الأصدقاء
  Stream<QuerySnapshot> getFriendRequestsStream() {
    return _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('requests')
        .snapshots();
  }

  // جلب جميع محادثات المستخدم
  Future<QuerySnapshot> getAllMessages() async {
    return await _firestore.collection('messages').get();
  }

  // جلب المحادثات غير المقروءة من غرفة محددة
  Future<QuerySnapshot> getUnreadConversations(String messageDocId) async {
    return await _firestore
        .collection('messages')
        .doc(messageDocId)
        .collection('conversations')
        .where('unreadMessage', isEqualTo: true)
        .get();
  }

  // Stream للمحادثات غير المقروءة
  Stream<QuerySnapshot> getUnreadConversationsStream(String messageDocId) {
    return _firestore
        .collection('messages')
        .doc(messageDocId)
        .collection('conversations')
        .where('unreadMessage', isEqualTo: true)
        .snapshots();
  }
}