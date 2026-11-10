import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/notifications/domain/data_sources/notifications_data_source.dart';


class FakeNotificationsDataSource implements NotificationsDataSource {
  // ===== getNotificationsStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? notificationsStream;
  int getNotificationsStreamCallCount = 0;
  String? lastNotificationsUserId;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream({
    required String userId,
  }) {
    getNotificationsStreamCallCount++;
    lastNotificationsUserId = userId;
    return notificationsStream!;
  }

  // ===== getDoc =====
  Map<String, DocumentSnapshot<Map<String, dynamic>>> docResponses = {};
  int getDocCallCount = 0;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  }) async {
    getDocCallCount++;
    return docResponses['$collectionPath/$docId']!;
  }

  // ===== getPostData =====
  ({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })? getPostDataResult;
  int getPostDataCallCount = 0;

  @override
  Future<({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    getPostDataCallCount++;
    return getPostDataResult!;
  }

  // ===== getPostLikesCount =====
  int getPostLikesCountResult = 0;
  int getPostLikesCountCallCount = 0;

  @override
  Future<int> getPostLikesCount({required String postId}) async {
    getPostLikesCountCallCount++;
    return getPostLikesCountResult;
  }

  // ===== getCommentsWithLikes =====
  List<QueryDocumentSnapshot<Map<String, dynamic>>> commentsWithLikesResult = [
  ];
  int getCommentsWithLikesCallCount = 0;

  @override
  Future<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCommentsWithLikes({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    getCommentsWithLikesCallCount++;
    return commentsWithLikesResult;
  }

  // ===== getAccountMap =====
  Map<String, dynamic> getAccountMapResult = {};
  int getAccountMapCallCount = 0;

  @override
  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
  }) async {
    getAccountMapCallCount++;
    return getAccountMapResult;
  }

  // ===== setSupDoc =====
  int setSupDocCallCount = 0;
  String? lastSetSupDocId;
  String? lastSetSupCollectionPath;
  Map<String, dynamic>? lastSetSupData;
  bool? lastSetSupIsMerge;

  @override
  Future<void> setSupDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    setSupDocCallCount++;
    lastSetSupDocId = docId;
    lastSetSupCollectionPath = collectionPath;
    lastSetSupData = data;
    lastSetSupIsMerge = isMerge;
  }

  // ===== updateDoc =====
  int updateDocCallCount = 0;
  String? lastUpdateDocId;
  String? lastUpdateDocCollectionPath;
  Map<String, dynamic>? lastUpdateDocData;

  @override
  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    updateDocCallCount++;
    lastUpdateDocId = docId;
    lastUpdateDocCollectionPath = collectionPath;
    lastUpdateDocData = data;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeNotificationsDataSource.${invocation.memberName} not stubbed',
      );
}