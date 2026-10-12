import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/post_model.dart';


abstract class ProfileRepository{

  Future<String> uploadImage({
    required PostModel postModel,
    required String collectionPath,
    required String imageType,
  });

  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    DocumentSnapshot? lastDoc,
  });

  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  });

  Future<bool> hasMeLiked(String postId);

  Future<void> deleteFriendship(String userId);

  Future<bool> checkFriendExists(String userId);

  Future<bool> checkRequestExists(String userId);

  Future<void> deleteFriendRequest(String userId);

  Future<List<MyModel>> getFriends(String userId);

  Future<Map<String, dynamic>> getAccountData(String userId);

  Future<void> addFriend(String docId, MyModel friendInfo);

  Future<({int? comments, int? likes})> getPostCounts(String postId);

  Future<void> sendFriendRequest(String userId, MyModel friendInfo);

  Future<({DocumentSnapshot? info, DocumentSnapshot? account})> getProfileInfo(String uId);
}