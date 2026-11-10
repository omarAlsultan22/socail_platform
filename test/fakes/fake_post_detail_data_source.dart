import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/post_detail/domain/data_sources/post_detail_data_source.dart';


class FakePostDetailDataSource implements PostDetailDataSource {
  // ===== getPostData =====
  ({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })? getPostDataResult;
  int getPostDataCallCount = 0;
  String? lastPostDataPostId;
  String? lastPostDataUserId;

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
    lastPostDataPostId = postId;
    lastPostDataUserId = userId;
    return getPostDataResult!;
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

  // ===== getCount =====
  int likesCountResult = 0;
  int getCountCallCount = 0;

  @override
  Future<AggregateQuerySnapshot> getCount({
    required String collectionPath,
    required DocumentReference docRef,
  }) async {
    getCountCallCount++;
    // AggregateQuerySnapshot — صعب — نستخدم fakeFirestore
    throw UnimplementedError('استخدم fakeFirestore');
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

  // ===== getAccountMap =====
  Map<String, dynamic> accountMapResult = {};
  int getAccountMapCallCount = 0;

  @override
  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
  }) async {
    getAccountMapCallCount++;
    return accountMapResult;
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

  // ===== getSpecificDocRef =====
  DocumentReference? specificDocRefResult;

  @override
  DocumentReference getSpecificDocRef({
    required String docId,
    required String collectionPath,
    required DocumentReference docRef,
  }) {
    return specificDocRefResult!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakePostDetailDataSource.${invocation.memberName} not stubbed',
      );
}