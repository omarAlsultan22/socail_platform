import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/public/domain/data_sources/public_data_source.dart';


class FakePublicDataSource implements PublicDataSource {
  // ===== getSubCollection =====
  QuerySnapshot<Map<String, dynamic>>? subCollectionResult;
  int getSubCollectionCallCount = 0;
  String? lastSubDocId;
  String? lastSubSupCollectionPath;
  String? lastSubSubCollectionPath;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    getSubCollectionCallCount++;
    lastSubDocId = docId;
    lastSubSupCollectionPath = supCollectionPath;
    lastSubSubCollectionPath = subCollectionPath;
    return subCollectionResult!;
  }

  // ===== getDocumentsWithWhereIn =====
  QuerySnapshot? documentsWithWhereInResult;
  int getDocumentsWithWhereInCallCount = 0;
  DocumentSnapshot? lastLastPostDoc;
  List<String>? lastFriendsUIds;
  int? lastLimit;

  @override
  Future<QuerySnapshot> getDocumentsWithWhereIn({
    required DocumentSnapshot? lastPostDoc,
    required List<String> friendsUIds,
    required int limit,
  }) async {
    getDocumentsWithWhereInCallCount++;
    lastLastPostDoc = lastPostDoc;
    lastFriendsUIds = friendsUIds;
    lastLimit = limit;
    return documentsWithWhereInResult!;
  }

  // ===== getDoc =====
  DocumentSnapshot<Map<String, dynamic>>? docResult;
  int getDocCallCount = 0;
  String? lastDocId;
  String? lastDocCollectionPath;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  }) async {
    getDocCallCount++;
    lastDocId = docId;
    lastDocCollectionPath = collectionPath;
    return docResult!;
  }

  // ===== getPostCounts =====
  ({int? commentsCount, int? likesCount}) postCountsResult = (commentsCount: 0, likesCount: 0);
  int getPostCountsCallCount = 0;
  String? lastPostCountsPostId;

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    getPostCountsCallCount++;
    lastPostCountsPostId = postId;
    return postCountsResult;
  }

  // ===== getQuery =====
  QuerySnapshot<Map<String, dynamic>>? queryResult;
  int getQueryCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getQuery({
    required int limit,
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
    required DocumentSnapshot? lastStatusDoc,
  }) async {
    getQueryCallCount++;
    return queryResult!;
  }

  // ===== getStatusesByUser =====
  QuerySnapshot<Map<String, dynamic>>? statusesByUserResult;
  int getStatusesByUserCallCount = 0;
  String? lastStatusesByUserUserId;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getStatusesByUser({
    required String userId,
  }) async {
    getStatusesByUserCallCount++;
    lastStatusesByUserUserId = userId;
    return statusesByUserResult!;
  }

  // ===== getRefAndSetDoc =====
  String getRefAndSetDocResult = 'generated-id';
  int getRefAndSetDocCallCount = 0;
  String? lastSetDocId;
  String? lastSetCollectionPath;
  Map<String, dynamic>? lastSetData;
  bool? lastSetIsMerge;

  @override
  Future<String> getRefAndSetDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    getRefAndSetDocCallCount++;
    lastSetDocId = docId;
    lastSetCollectionPath = collectionPath;
    lastSetData = data;
    lastSetIsMerge = isMerge;
    return getRefAndSetDocResult;
  }

  // ===== deleteSupDoc =====
  int deleteSupDocCallCount = 0;
  String? lastDeleteDocId;
  String? lastDeleteCollectionPath;

  @override
  Future<void> deleteSupDoc({
    required String collectionPath,
    required String docId,
  }) async {
    deleteSupDocCallCount++;
    lastDeleteDocId = docId;
    lastDeleteCollectionPath = collectionPath;
  }

  // ===== setSubDoc =====
  int setSubDocCallCount = 0;
  String? lastSetSubSupDocId;
  String? lastSetSubSubDocId;
  String? lastSetSupCollectionPath;
  String? lastSetSubCollectionPath;
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
    lastSetSupCollectionPath = supCollectionPath;
    lastSetSubCollectionPath = subCollectionPath;
    lastSetSubData = data;
  }

  // باقي دوال FirestoreService — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakePublicDataSource.${invocation.memberName} not stubbed',
      );
}