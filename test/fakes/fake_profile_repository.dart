import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';


class FakeProfileRepository implements ProfileRepository {
  // ===== getPosts =====
  QuerySnapshot? postsResult;
  Object? postsError;
  int getPostsCallCount = 0;
  String? lastUserId;
  int? lastLimit;
  String? lastPostType;
  DocumentSnapshot? lastLastDoc;

  @override
  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    DocumentSnapshot? lastDoc,
  }) async {
    getPostsCallCount++;
    lastUserId = userId;
    lastLimit = limit;
    lastPostType = postType;
    lastLastDoc = lastDoc;
    if (postsError != null) throw postsError!;
    return postsResult!;
  }

  // ===== getAccountData =====
  Object? getAccountDataError;
  int getAccountDataCallCount = 0;
  String? lastGetAccountDataUserId;
  Map<String, dynamic> getAccountDataResult = {};

  @override
  Future<Map<String, dynamic>> getAccountData(String userId) async {
    getAccountDataCallCount++;
    return getAccountDataResult;
  }

  // ===== getPostCounts =====
  ({int? comments, int? likes}) postCountsResult = (comments: 0, likes: 0);
  int getPostCountsCallCount = 0;

  @override
  Future<({int? comments, int? likes})> getPostCounts(String postId) async {
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

  // ===== getFriends =====
  List<MyModel> getFriendsResult = [];
  Object? getFriendsError;
  int getFriendsCallCount = 0;
  String? lastGetFriendsUserId;

  @override
  Future<List<MyModel>> getFriends(String userId) async {
    getFriendsCallCount++;
    lastGetFriendsUserId = userId;
    if (getFriendsError != null) throw getFriendsError!;
    return getFriendsResult;
  }

  // ===== getProfileInfo =====
  ({DocumentSnapshot? info, DocumentSnapshot? account}) getProfileInfoResult =
  (info: null, account: null);
  int getProfileInfoCallCount = 0;
  String? lastGetProfileInfoUid;

  @override
  Future<({DocumentSnapshot? info, DocumentSnapshot? account})> getProfileInfo(
      String uId) async {
    getProfileInfoCallCount++;
    lastGetProfileInfoUid = uId;
    return getProfileInfoResult;
  }

  // ===== uploadImage =====
  String uploadImageResult = 'new-post-id';
  int uploadImageCallCount = 0;
  String? lastUploadImageType;
  String? lastUploadCollectionPath;
  PostModel? lastUploadPostModel;

  @override
  Future<String> uploadImage({
    required String imageType,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    uploadImageCallCount++;
    lastUploadImageType = imageType;
    lastUploadCollectionPath = collectionPath;
    lastUploadPostModel = postModel;
    return uploadImageResult;
  }

// ===== sendFriendRequest =====
  int sendFriendRequestCallCount = 0;
  String? lastSendFriendRequestUserId;
  MyModel? lastSendFriendRequestFriendInfo;

  @override
  Future<void> sendFriendRequest(String userId, MyModel friendInfo) async {
    sendFriendRequestCallCount++;
    lastSendFriendRequestUserId = userId;
    lastSendFriendRequestFriendInfo = friendInfo;
  }

  // ===== deleteFriendRequest =====
  int deleteFriendRequestCallCount = 0;
  String? lastDeleteFriendRequestUserId;

  @override
  Future<void> deleteFriendRequest(String userId) async {
    deleteFriendRequestCallCount++;
    lastDeleteFriendRequestUserId = userId;
  }

  // ===== deleteFriendship =====
  int deleteFriendshipCallCount = 0;
  String? lastDeleteFriendshipUserId;

  @override
  Future<void> deleteFriendship(String userId) async {
    deleteFriendshipCallCount++;
    lastDeleteFriendshipUserId = userId;
  }

  // ===== addFriend =====
  int addFriendCallCount = 0;
  String? lastAddFriendUserId;
  MyModel? lastAddFriendFriendInfo;

  @override
  Future<void> addFriend(String userId, MyModel friendInfo) async {
    addFriendCallCount++;
    lastAddFriendUserId = userId;
    lastAddFriendFriendInfo = friendInfo;
  }

  // ===== checkRequestExists =====
  bool checkRequestExistsResult = false;
  int checkRequestExistsCallCount = 0;

  @override
  Future<bool> checkRequestExists(String userId) async {
    checkRequestExistsCallCount++;
    return checkRequestExistsResult;
  }

  // ===== checkFriendExists =====
  bool checkFriendExistsResult = false;
  int checkFriendExistsCallCount = 0;

  @override
  Future<bool> checkFriendExists(String userId) async {
    checkFriendExistsCallCount++;
    return checkFriendExistsResult;
  }

  // ===== getVideos =====
  QuerySnapshot? videosResult;
  Object? videosError;
  int getVideosCallCount = 0;
  String? lastVideosUserId;
  int? lastVideosLimit;
  DocumentSnapshot? lastVideosLastDoc;

  @override
  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  }) async {
    getVideosCallCount++;
    lastVideosUserId = userId;
    lastVideosLimit = limit;
    lastVideosLastDoc = lastDoc;
    if (videosError != null) throw videosError!;
    return videosResult!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeProfileRepository.${invocation.memberName} not stubbed',
      );
}