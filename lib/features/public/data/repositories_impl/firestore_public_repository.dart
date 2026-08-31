import 'package:social_app/core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class FirestorePublicRepository extends PublicRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب قائمة الأصدقاء
  @override
  Future<QuerySnapshot> getFriendsList({required String uId}) async {
    return await _firestore
        .collection('users')
        .doc(uId)
        .collection('friends')
        .get();
  }

  // جلب البوستات من Firebase
  @override
  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  }) async {
    var query = _firestore
        .collection('posts')
        .where('userId', whereIn: friendsUIds)
        .where('postType', isEqualTo: 'post')
        .orderBy('dateTime', descending: true);

    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc);
    }

    return await query.limit(limit).get();
  }

  // جلب البوستات المحذوفة للمستخدم
  @override
  Future<QuerySnapshot> getDeletedPosts() async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('deleted_posts')
        .get();
  }

  // جلب بيانات المستخدم من accounts
  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    return await _firestore.collection('accounts').doc(userId).get();
  }

  // جلب عدد اللايكات والتعليقات لبوست
  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final results = await Future.wait([
      postRef.collection('likesList').count().get(),
      postRef.collection('commentsList').count().get(),
    ]);
    return (
    likesCount: results[0].count,
    commentsCount: results[1].count,
    );
  }

  // جلب قائمة الأصدقاء للستوريس (مع pagination)
  @override
  Future<QuerySnapshot> getFriendsForStatus({
    required DocumentSnapshot? lastStatusDoc,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('friends');

    if (lastStatusDoc != null) {
      query = query.startAfterDocument(lastStatusDoc);
    }

    return await query.limit(limit).get();
  }

  // جلب الستوريس المحذوفة
  @override
  Future<QuerySnapshot> getDeletedStatuses() async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('deleted_statuses')
        .get();
  }

  // جلب الستوريس لمستخدم محدد
  @override
  Future<QuerySnapshot> getStatusesForUser(String userId) async {
    return await _firestore
        .collection('status')
        .where('userId', isEqualTo: userId)
        .orderBy(FieldPath.fromString('dateTime'), descending: true)
        .get();
  }

  // إضافة بوست جديد
  @override
  Future<void> addPostToFirestore(PostModel postModel) async {
    final docRef = _firestore.collection('posts').doc(postModel.docId);
    await docRef.set(postModel.toJson(), SetOptions(merge: true));
  }

  // إضافة status جديد
  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    final docRef = _firestore.collection('status').doc(statusModel.docId);
    await docRef.set(statusModel.toJson(), SetOptions(merge: true));
  }

  // حذف بوست
  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // إضافة بوست إلى deleted_posts
  @override
  Future<void> addToDeletedPosts(String postId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('deleted_posts')
        .doc(postId)
        .set({});
  }

  // حذف status
  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    await _firestore.collection('status').doc(statusId).delete();
  }

  // إضافة status إلى deleted_statuses
  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uId)
        .collection('deleted_statuses')
        .doc(statusId)
        .set({});
  }

  // جلب بيانات حساب المستخدم
  @override
  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc) async {
    return await getAccountMap(userDoc: userDoc);
  }
}