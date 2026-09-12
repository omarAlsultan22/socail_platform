import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/services/user_account_service.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../data_sources/remote/firestore_profile_service.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';


class FirestoreProfileRepository implements ProfileRepository {
  final SessionService _sessionService;
  final FirestoreProfileService _repository;
  final UserAccountService _userAccountService;

  FirestoreProfileRepository({
    required SessionService sessionService,
    required FirestoreProfileService repository,
    required UserAccountService userAccountService,
  })
      : _repository = repository,

        _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  Future<({ProfileInfoModel? info, UserModel? account})> getProfileInfo(
      String uid) async {
    final results = await Future.wait([
      _repository.getSupDoc(docId: uid, collectionPath: 'info'),
      _repository.getSupDoc(docId: uid, collectionPath: 'accounts'),
    ]);

    final infoDoc = results[0] as DocumentSnapshot;
    final accountDoc = results[1] as DocumentSnapshot;

    ProfileInfoModel? info;
    UserModel? account;

    if (infoDoc.exists) {
      info = ProfileInfoModel.fromJson(infoDoc.data() as Map<String, dynamic>);
    }
    if (accountDoc.exists) {
      account = UserModel.fromJson(accountDoc.data() as Map<String, dynamic>);
    }

    return (info: info, account: account);
  }

  @override
  Future<ProfileInfoModel?> getInfo(String uid) async {
    final doc = await _repository.getSupDoc(docId: uid, collectionPath: 'info');
    if (doc.exists) {
      return ProfileInfoModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<QuerySnapshot> getPosts({
    required int limit,
    required String userId,
    required String postType,
    required DocumentSnapshot? lastDoc,
  }) async {
    return await _repository.getPosts(
        limit: limit,
        userId: userId,
        postType: postType,
        lastPostDoc: lastDoc
    );
  }

  @override
  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  }) async {
    return await _repository.getPosts(
        limit: limit,
        userId: userId,
        postType: 'video',
        lastPostDoc: lastDoc
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountData(String userId) async {
    final doc = await _repository.getSupDoc(
        docId: userId, collectionPath: 'accounts'
    );
    return await _userAccountService.getAccountMap(userDoc: doc);
  }

  @override
  Future<({int? comments, int? likes})> getPostCounts(String postId) async {
    final postRef = _repository.docRef(docId: postId, collectionPath: 'posts');
    final results = await Future.wait([
      _repository.getCount(docRef: postRef, collectionPath: 'likesList'),
      _repository.getCount(docRef: postRef, collectionPath: 'commentsList')
    ]);
    return (likes: results[0].count, comments: results[1].count);
  }

  @override
  Future<String> addPost(PostModel postModel) async {
    final docId = await _repository.createAndSetDoc(
      collectionPath: 'posts',
      data: postModel.postToMap(),
    );
    postModel.docId = docId;
    return docId;
  }

  @override
  Future<void> updatePost(PostModel postModel) async {
    if (postModel.docId != null) {
      await _repository.getRefAndSetDoc(
        isMerge: true,
        docId: postModel.docId,
        collectionPath: 'posts',
        data: postModel.postToMap(),
      );
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await _repository.deleteSupDoc(collectionPath: 'posts', docId: postId);
  }

  @override
  Future<String> uploadImage({
    required String imageType,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    return _repository.uploadImage(
        imageType: imageType,
        postModel: postModel,
        collectionPath: collectionPath,
        currentUid: _sessionService.currentUid
    );
  }

  @override
  Future<void> sendFriendRequest(String userId, UserModel friendInfo) async {
    await _repository.setSubDoc(
      supDocId: userId,
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      data: friendInfo.toJson(),
      subDocId: friendInfo.userId ?? '',
    );
  }

  @override
  Future<void> deleteFriendRequest(String userId) async {
    await _repository.deleteSubDoc(
      supDoc: userId,
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      subDoc: _sessionService.currentUid,

    );
  }

  @override
  Future<void> deleteFriendship(String userId) async {
    await Future.wait([
      _repository.deleteSubDoc(
          subDoc: userId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          supDoc: _sessionService.currentUid
      ),
      _repository.deleteSubDoc(
          supDoc: userId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          subDoc: _sessionService.currentUid
      ),
    ]);
  }

  @override
  Future<void> addFriend(String docId, UserModel friendInfo) async {
    await _repository.setSubDoc(
        subDocId: docId,
        supCollectionPath: 'users',
        supDocId: friendInfo.userId,
        subCollectionPath: 'friends',
        data: friendInfo.toJson()
    );
  }

  @override
  Future<List<UserModel>> getFriends(String userId) async {
    final snapshot = await _repository.getSubCollection(
        docId: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );

    final List<UserModel> friends = [];
    for (final doc in snapshot.docs) {
      final user = await _userAccountService.getUserModelData(id: doc.id);
      friends.add(user);
    }
    return friends;
  }

  @override
  Future<bool> checkRequestExists(String userId) async {
    final doc = await _repository.getSubDoc(
        subDoc: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'requests',
        supDoc: _sessionService.currentUid
    );
    return doc.exists;
  }

  @override
  Future<bool> checkFriendExists(String userId) async {
    final doc = await _repository.getSubDoc(
        subDoc: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        supDoc: _sessionService.currentUid
    );
    return doc.exists;
  }
}