import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/features/profile/domain/data_sources/profile_data_source.dart';


class FakeProfileDataSource implements ProfileDataSource {
  // ===== getDoc =====
  Map<String, DocumentSnapshot<Map<String, dynamic>>> docResponses = {};
  int getDocCallCount = 0;
  String? lastGetDocId;
  String? lastGetDocCollectionPath;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  }) async {
    getDocCallCount++;
    lastGetDocId = docId;
    lastGetDocCollectionPath = collectionPath;
    return docResponses['$collectionPath/$docId']!;
  }

  // ===== getPosts =====
  QuerySnapshot? postsResult;
  int getPostsCallCount = 0;
  String? lastUserId;
  int? lastLimit;
  String? lastPostType;
  DocumentSnapshot? lastLastPostDoc;

  @override
  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    required DocumentSnapshot? lastPostDoc,
  }) async {
    getPostsCallCount++;
    lastUserId = userId;
    lastLimit = limit;
    lastPostType = postType;
    lastLastPostDoc = lastPostDoc;
    return postsResult!;
  }

  // ===== uploadImage =====
  String uploadImageResult = 'new-post-id';
  int uploadImageCallCount = 0;
  String? lastImageType;
  String? lastCurrentUid;
  String? lastUploadCollectionPath;

  @override
  Future<String> uploadImage({
    required String imageType,
    required String currentUid,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    uploadImageCallCount++;
    lastImageType = imageType;
    lastCurrentUid = currentUid;
    lastUploadCollectionPath = collectionPath;
    return uploadImageResult;
  }

  // ===== getCount =====
  // ملاحظة: AggregateQuerySnapshot — صعب بناؤه يدوياً
  // للتخزين المؤقت — نعيد null ونستخدم fakeFirestore في الاختبار
  AggregateQuerySnapshot? getCountResult;
  int getCountCallCount = 0;

  @override
  Future<AggregateQuerySnapshot> getCount({
    required String collectionPath,
    required DocumentReference docRef,
  }) async {
    getCountCallCount++;
    return getCountResult!;
  }

  // ===== getDocRef =====
  DocumentReference<Map<String, dynamic>>? docRefResult;

  @override
  DocumentReference<Map<String, dynamic>> getDocRef({
    required String? docId,
    required String collectionPath,
  }) {
    return docRefResult!;
  }

  // ===== getSubDoc =====
  Map<String, DocumentSnapshot<Map<String, dynamic>>> subDocResponses = {};
  int getSubDocCallCount = 0;
  String? lastGetSubSupDoc;
  String? lastGetSubSubDoc;
  String? lastGetSubSupCollectionPath;
  String? lastGetSubSubCollectionPath;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getSubDoc({
    required String supDoc,
    required String subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    getSubDocCallCount++;
    lastGetSubSupDoc = supDoc;
    lastGetSubSubDoc = subDoc;
    lastGetSubSupCollectionPath = supCollectionPath;
    lastGetSubSubCollectionPath = subCollectionPath;
    return subDocResponses['$supCollectionPath/$supDoc/$subCollectionPath/$subDoc']!;
  }

  // ===== setSubDoc =====
  int setSubDocCallCount = 0;
  String? lastSetSubSupDocId;
  String? lastSetSubSubDocId;
  String? lastSetSubSupCollectionPath;
  String? lastSetSubSubCollectionPath;
  Map<String, dynamic>? lastSetSubData;

  @override
  Future<void> setSubDoc({
    required String? supDocId,
    required String? subDocId,
    required String supCollectionPath,
    required String subCollectionPath,
    required Map<String, dynamic> data,
  }) async {
    setSubDocCallCount++;
    lastSetSubSupDocId = supDocId;
    lastSetSubSubDocId = subDocId;
    lastSetSubSupCollectionPath = supCollectionPath;
    lastSetSubSubCollectionPath = subCollectionPath;
    lastSetSubData = data;
  }

  // ===== deleteSubDoc =====
  int deleteSubDocCallCount = 0;
  String? lastDeleteSupDoc;
  String? lastDeleteSubDoc;
  String? lastDeleteSupCollectionPath;
  String? lastDeleteSubCollectionPath;

  @override
  Future<void> deleteSubDoc({
    required String? supDoc,
    required String? subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    deleteSubDocCallCount++;
    lastDeleteSupDoc = supDoc;
    lastDeleteSubDoc = subDoc;
    lastDeleteSupCollectionPath = supCollectionPath;
    lastDeleteSubCollectionPath = subCollectionPath;
  }

  // ===== getSubCollection =====
  QuerySnapshot<Map<String, dynamic>>? subCollectionResult;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    return subCollectionResult!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeProfileDataSource.${invocation.memberName} not stubbed',
      );
}