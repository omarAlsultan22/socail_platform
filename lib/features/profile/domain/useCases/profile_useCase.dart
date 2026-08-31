import 'package:flutter/cupertino.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/converters/Info_data_converter.dart';
import '../../../../core/constants/user_details.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../data/repositories_impl/firestore_profile_repository.dart';


class ProfileUseCases {
  final ProfileRepository _repository;

  ProfileUseCases({required ProfileRepository repository})
      : _repository = repository;

  Future<ProfileInfoModel?> executeGetProfileInfo(String uid) async {
    final data = await _repository.getProfileInfo(uid);
    if (data.info != null) return data.info;

    if (data.account != null) {
      final converter = InfoDataConverter(
        userInfo: null,
        userAccount: data.account!,
      );
      return converter.infoModel;
    }
    return null;
  }

  Future<ProfileInfoModel?> executeGetInfo(String uid) async {
    return await _repository.getInfo(uid);
  }

  Future<({bool hasMore, QueryDocumentSnapshot<Object?>? lastDoc, List<dynamic> posts})> executeGetProfileData(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      userId: userId,
      postType: 'post',
      lastDoc: lastDoc,
      limit: 10,
    );

    if (snapshot.docs.isEmpty) {
      return (posts: [], lastDoc: null, hasMore: false);
    }

    final newLastDoc = snapshot.docs.last;
    final List<PostModel> posts = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final accountData = await _repository.getAccountData(postFields['userId']);
        final counts = await _repository.getPostCounts(doc.id);

        final isActive = postFields['friendId'] != null;
        Map<String, dynamic> friendAccount = {};

        if (isActive) {
          final friendAccountDoc = await _repository.getAccountData(postFields['friendId']);
          friendAccount = friendAccountDoc;
        }

        final post = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          ...friendAccount,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        posts.add(post);
      } catch (e) {
        debugPrint('Error processing post ${doc.id}: $e');
        continue;
      }
    }

    posts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    return (posts: posts, lastDoc: newLastDoc, hasMore: snapshot.docs.length == 10);
  }

  Future<({bool hasMore, List<dynamic> images, QueryDocumentSnapshot<Object?>? lastDoc})> executeGetProfileImages(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      userId: userId,
      postType: 'profileImage',
      lastDoc: lastDoc,
      limit: 10,
    );

    if (snapshot.docs.isEmpty) {
      return (images: [], lastDoc: null, hasMore: false);
    }

    final newLastDoc = snapshot.docs.last;
    final accountData = await _repository.getAccountData(userId);
    final List<PostModel> images = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);

        final image = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        images.add(image);
      } catch (e) {
        debugPrint('Error processing profile image ${doc.id}: $e');
        continue;
      }
    }

    images.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    return (images: images, lastDoc: newLastDoc, hasMore: snapshot.docs.length == 10);
  }

  Future<({List<dynamic> covers, bool hasMore, QueryDocumentSnapshot<Object?>? lastDoc})> executeGetCoverImages(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      userId: userId,
      postType: 'coverImage',
      lastDoc: lastDoc,
      limit: 10,
    );

    if (snapshot.docs.isEmpty) {
      return (covers: [], lastDoc: null, hasMore: false);
    }

    final newLastDoc = snapshot.docs.last;
    final accountData = await _repository.getAccountData(userId);
    final List<PostModel> covers = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);

        final cover = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        covers.add(cover);
      } catch (e) {
        debugPrint('Error processing cover image ${doc.id}: $e');
        continue;
      }
    }

    covers.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    return (covers: covers, lastDoc: newLastDoc, hasMore: snapshot.docs.length == 10);
  }

  Future<({bool hasMore, QueryDocumentSnapshot<Object?>? lastDoc, List<dynamic> videos})> executeGetVideosPosts(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getVideos(
      userId: userId,
      lastDoc: lastDoc,
      limit: 10,
    );

    if (snapshot.docs.isEmpty) {
      return (videos: [], lastDoc: null, hasMore: false);
    }

    final newLastDoc = snapshot.docs.last;
    final accountData = await _repository.getAccountData(userId);
    final List<PostModel> videos = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);

        final video = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        videos.add(video);
      } catch (e) {
        debugPrint('Error processing video ${doc.id}: $e');
        continue;
      }
    }

    videos.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    return (videos: videos, lastDoc: newLastDoc, hasMore: snapshot.docs.length == 10);
  }

  Future<void> executeInsertPost(PostModel postModel) async {
    if (postModel.userId == null) {
      final userModel = await getUserAccountData();
      postModel
        ..userId = userModel.userId
        ..userName = userModel.userName
        ..userImage = userModel.userImage;
    }

    if (postModel.docId != null) {
      await _repository.updatePost(postModel);
    } else {
      await _repository.addPost(postModel);
    }
  }

  Future<void> executeUploadImage({
    required PostModel postModel,
    required String collection,
    required String imageType,
  }) async {
    final userModel = await getUserAccountData();
    postModel
      ..userId = userModel.userId
      ..userName = userModel.userName
      ..userImage = userModel.userImage;

    await _repository.uploadImage(
      postModel: postModel,
      collection: collection,
      imageType: imageType,
    );
  }

  Future<void> executeSendFriendRequest(String userId, UserModel friendInfo) async {
    await _repository.sendFriendRequest(userId, friendInfo);
  }

  Future<void> executeDeleteFriendRequest(String userId) async {
    await _repository.deleteFriendRequest(userId, UserDetails.uId);
  }

  Future<void> executeDeleteFriendship(String userId) async {
    await _repository.deleteFriendship(userId, UserDetails.uId);
  }

  Future<void> executeAddFriend(String userId, UserModel friendInfo) async {
    await _repository.addFriend(userId, friendInfo);
  }

  Future<List<UserModel>> executeGetFriends(String userId) async {
    return await _repository.getFriends(userId);
  }

  Future<bool> executeCheckIsRequest(String userId) async {
    return await _repository.checkRequestExists(userId, UserDetails.uId);
  }

  Future<bool> executeCheckIsFriend(String userId) async {
    return await _repository.checkFriendExists(userId, UserDetails.uId);
  }

  Future<void> executeDeletePost(String postId) async {
    await _repository.deletePost(postId);
  }
}