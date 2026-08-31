import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class ProfileRepository {

  Future<ProfileInfoModel?> getInfo(String uid);

  Future<QuerySnapshot> getPosts({
    required String userId,
    required String postType,
    required DocumentSnapshot? lastDoc,
    required int limit,
  });

  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  });

  Future<Map<String, dynamic>> getAccountData(String userId);

  Future<({int? comments, int? likes})> getPostCounts(String postId);

  Future<String> addPost(PostModel postModel);

  Future<void> updatePost(PostModel postModel);

  Future<void> deletePost(String postId);

  Future<String> uploadImage({
    required PostModel postModel,
    required String collection,
    required String imageType,
  });

  Future<void> sendFriendRequest(String userId, UserModel friendInfo);

  Future<void> deleteFriendRequest(String userId, String currentUserId);

  Future<void> deleteFriendship(String userId, String currentUserId);

  Future<void> addFriend(String docId, UserModel friendInfo);

  Future<List<UserModel>> getFriends(String userId);

  Future<bool> checkRequestExists(String userId, String currentUserId);

  Future<bool> checkFriendExists(String userId, String currentUserId);

  Future<({ProfileInfoModel? info, UserModel? account})> getProfileInfo(String uid);
}