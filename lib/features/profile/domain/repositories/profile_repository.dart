import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class ProfileRepository {

  Future<String> uploadImage({
    required PostModel postModel,
    required String collectionPath,
    required String imageType,
  });

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

  Future<void> deletePost(String postId);

  Future<String> addPost(PostModel postModel);

  Future<void> updatePost(PostModel postModel);

  Future<void> deleteFriendship(String userId);

  Future<ProfileInfoModel?> getInfo(String uid);

  Future<bool> checkFriendExists(String userId);

  Future<bool> checkRequestExists(String userId);

  Future<void> deleteFriendRequest(String userId);

  Future<List<UserModel>> getFriends(String userId);

  Future<Map<String, dynamic>> getAccountData(String userId);

  Future<void> addFriend(String docId, UserModel friendInfo);

  Future<({int? comments, int? likes})> getPostCounts(String postId);

  Future<void> sendFriendRequest(String userId, UserModel friendInfo);

  Future<({ProfileInfoModel? info, UserModel? account})> getProfileInfo(String uid);
}