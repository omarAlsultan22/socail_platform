import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class FakePublicRepository implements PublicRepository {
  // ===== getFriendsList =====
  QuerySnapshot<Map<String, dynamic>>? friendsListResult;
  int getFriendsListCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList() async {
    getFriendsListCallCount++;
    return friendsListResult!;
  }

  // ===== fetchPostsQuery =====
  QuerySnapshot? postsQueryResult;
  int fetchPostsQueryCallCount = 0;
  List<String>? lastFriendsUIds;
  DocumentSnapshot? lastLastPostDoc;
  int? lastLimit;

  @override
  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  }) async {
    fetchPostsQueryCallCount++;
    lastFriendsUIds = friendsUIds;
    lastLastPostDoc = lastPostDoc;
    lastLimit = limit;
    return postsQueryResult!;
  }

  // ===== getDeletedPosts =====
  QuerySnapshot<Map<String, dynamic>>? deletedPostsResult;
  int getDeletedPostsCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedPosts() async {
    getDeletedPostsCallCount++;
    return deletedPostsResult!;
  }

  // ===== getAccountData =====
  DocumentSnapshot? accountDataResult;
  int getAccountDataCallCount = 0;

  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    getAccountDataCallCount++;
    return accountDataResult!;
  }

  // ===== getAccountMap =====
  Map<String, dynamic> accountMapResult = {};
  int getAccountMapCallCount = 0;

  @override
  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc) async {
    getAccountMapCallCount++;
    return accountMapResult;
  }

  // ===== getPostCounts =====
  ({int? commentsCount, int? likesCount}) postCountsResult =
  (commentsCount: 0, likesCount: 0);
  int getPostCountsCallCount = 0;

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    getPostCountsCallCount++;
    return postCountsResult;
  }

  // ===== hasMeLiked =====
  bool hasMeLikedResult = false;
  int hasMeLikedCallCount = 0;

  @override
  Future<bool> hasMeLiked(String postId) async {
    hasMeLikedCallCount++;
    return hasMeLikedResult;
  }

  // ===== getFriendsForStatus =====
  QuerySnapshot<Map<String, dynamic>>? friendsForStatusResult;
  int getFriendsForStatusCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsForStatus({
    required int limit,
    required DocumentSnapshot? lastStatusDoc,
  }) async {
    getFriendsForStatusCallCount++;
    return friendsForStatusResult!;
  }

  // ===== getDeletedStatuses =====
  QuerySnapshot<Map<String, dynamic>>? deletedStatusesResult;
  int getDeletedStatusesCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses() async {
    getDeletedStatusesCallCount++;
    return deletedStatusesResult!;
  }

  // ===== getStatusesForUser =====
  QuerySnapshot<Map<String, dynamic>>? statusesForUserResult;
  int getStatusesForUserCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getStatusesForUser(
      String userId) async {
    getStatusesForUserCallCount++;
    return statusesForUserResult!;
  }

  // ===== addPostToFirestore =====
  int addPostToFirestoreCallCount = 0;
  PostModel? lastPostModel;
  Object? addPostToFirestoreError;

  @override
  Future<void> addPostToFirestore(PostModel postModel) async {
    addPostToFirestoreCallCount++;
    lastPostModel = postModel;
    if (addPostToFirestoreError != null) throw addPostToFirestoreError!;
  }

  // ===== addStatusToFirestore =====
  int addStatusToFirestoreCallCount = 0;
  PostModel? lastStatusModel;
  Object? addStatusToFirestoreError;

  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    addStatusToFirestoreCallCount++;
    lastStatusModel = statusModel;
    if (addStatusToFirestoreError != null) throw addStatusToFirestoreError!;
  }

  // ===== deletePostFromFirestore =====
  int deletePostFromFirestoreCallCount = 0;
  String? lastDeletedFromFirestorePostId;

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    deletePostFromFirestoreCallCount++;
    lastDeletedFromFirestorePostId = postId;
  }

  // ===== addToDeletedPosts =====
  int addToDeletedPostsCallCount = 0;
  String? lastDeletedPostId;

  @override
  Future<void> addToDeletedPosts(String postId) async {
    addToDeletedPostsCallCount++;
    lastDeletedPostId = postId;
  }

  // ===== deleteStatusFromFirestore =====
  int deleteStatusFromFirestoreCallCount = 0;
  String? lastDeletedFromFirestoreStatusId;

  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    deleteStatusFromFirestoreCallCount++;
    lastDeletedFromFirestoreStatusId = statusId;
  }

  // ===== addToDeletedStatuses =====
  int addToDeletedStatusesCallCount = 0;
  String? lastDeletedStatusId;

  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    addToDeletedStatusesCallCount++;
    lastDeletedStatusId = statusId;
  }

  // باقي دوال PublicRepository — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakePublicRepository.${invocation.memberName} not stubbed',
      );
}