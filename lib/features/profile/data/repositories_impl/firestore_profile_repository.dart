import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../shared/componentes/public_components.dart';


class FirestoreProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب معلومات المستخدم
  @override
  Future<({ProfileInfoModel? info, UserModel? account})> getProfileInfo(
      String uid) async {
    final results = await Future.wait([
      _firestore.collection('info').doc(uid).get(),
      _firestore.collection('accounts').doc(uid).get(),
    ]);

    final infoDoc = results[0] as DocumentSnapshot;
    final accountDoc = results[1] as DocumentSnapshot;

    ProfileInfoModel? info;
    UserModel? account;

    if (infoDoc.exists) {
      info = ProfileInfoModel.fromJson(infoDoc.data() as Map<String, dynamic>);
    }
    if (accountDoc.exists) {
      account = UserModel.fromJson(accountDoc.data() as Map<String, dynamic>);
    }

    return (info: info, account: account);
  }

  // جلب معلومات info فقط
  @override
  Future<ProfileInfoModel?> getInfo(String uid) async {
    final doc = await _firestore.collection('info').doc(uid).get();
    if (doc.exists) {
      return ProfileInfoModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // جلب البوستات
  @override
  Future<QuerySnapshot> getPosts({
    required String userId,
    required String postType,
    required DocumentSnapshot? lastDoc,
    required int limit,
  }) async {
    var query = _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('postType', isEqualTo: postType)
        .orderBy('dateTime', descending: true);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.limit(limit).get();
  }

  // جلب الفيديوهات
  @override
  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  }) async {
    var query = _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('pathType', isEqualTo: 'video')
        .orderBy('dateTime', descending: true);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.limit(limit).get();
  }

  // جلب بيانات الحساب
  @override
  Future<Map<String, dynamic>> getAccountData(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    return await getAccountMap(userDoc: doc);
  }

  // جلب عدد اللايكات والتعليقات
  @override
  Future<({int? comments, int? likes})> getPostCounts(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final results = await Future.wait([
      postRef.collection('likesList').count().get(),
      postRef.collection('commentsList').count().get(),
    ]);
    return (likes: results[0].count, comments: results[1].count);
  }

  // إضافة بوست
  @override
  Future<String> addPost(PostModel postModel) async {
    final docRef = _firestore.collection('posts').doc();
    postModel.docId = docRef.id;
    await docRef.set(postModel.postToMap(), SetOptions(merge: true));
    return docRef.id;
  }

  // تحديث بوست موجود
  @override
  Future<void> updatePost(PostModel postModel) async {
    if (postModel.docId != null) {
      final docRef = _firestore.collection('posts').doc(postModel.docId);
      await docRef.set(postModel.postToMap(), SetOptions(merge: true));
    }
  }

  // حذف بوست
  @override
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // رفع صورة (بروفايل أو كفر)
  @override
  Future<String> uploadImage({
    required PostModel postModel,
    required String collection,
    required String imageType,
  }) async {
    final docRef = _firestore.collection('posts').doc();
    await _firestore.collection(collection).doc(UserDetails.uId).set({
      imageType: docRef.path,
    }, SetOptions(merge: true));

    postModel.docId = docRef.id;
    await docRef.set(postModel.postToMap(), SetOptions(merge: true));
    return docRef.id;
  }

  // طلب صداقة
  @override
  Future<void> sendFriendRequest(String userId, UserModel friendInfo) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('requests')
        .doc(friendInfo.userId)
        .set(friendInfo.toJson());
  }

  // حذف طلب صداقة
  @override
  Future<void> deleteFriendRequest(String userId, String currentUserId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('requests')
        .doc(currentUserId)
        .delete();
  }

  // حذف صداقة
  @override
  Future<void> deleteFriendship(String userId, String currentUserId) async {
    await Future.wait([
      _firestore.collection('users').doc(currentUserId)
          .collection('friends')
          .doc(userId)
          .delete(),
      _firestore.collection('users').doc(userId).collection('friends').doc(
          currentUserId).delete(),
    ]);
  }

  // إضافة صديق
  @override
  Future<void> addFriend(String docId, UserModel friendInfo) async {
    await _firestore
        .collection('users')
        .doc(friendInfo.userId)
        .collection('friends')
        .doc(docId)
        .set(friendInfo.toJson());
  }

  // جلب الأصدقاء
  @override
  Future<List<UserModel>> getFriends(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    final List<UserModel> friends = [];
    for (final doc in snapshot.docs) {
      final user = await getUserModelData(id: doc.id);
      friends.add(user);
    }
    return friends;
  }

  // التحقق من وجود طلب
  @override
  Future<bool> checkRequestExists(String userId, String currentUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .doc(userId)
        .get();
    return doc.exists;
  }

  // التحقق من وجود صديق
  @override
  Future<bool> checkFriendExists(String userId, String currentUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(userId)
        .get();
    return doc.exists;
  }
}