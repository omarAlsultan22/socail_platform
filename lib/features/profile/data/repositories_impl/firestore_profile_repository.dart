import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../core/services/user_account_service.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../data_sources/remote/firestore_profile_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin.dart';


class FirestoreProfileRepository with BaseLikeMixin implements ProfileRepository {
  final SessionService _sessionService;
  final FirestoreProfileService _repository;
  final UserAccountService _userAccountService;

  FirestoreProfileRepository({
    required SessionService sessionService,
    required FirestoreProfileService repository,
    required UserAccountService userAccountService
  })
      : _repository = repository,
        _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  String get likeCollectionPath => throw UnimplementedError();

  @override
  FirestoreProfileService get repository => _repository;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<({DocumentSnapshot? info, DocumentSnapshot? account})> getProfileInfo(
      String uId) async {
    final results = await Future.wait([
      repository.getDoc(docId: uId, collectionPath: 'info'),
      repository.getDoc(docId: uId, collectionPath: 'accounts'),
    ]);

    final infoDoc = results[0] as DocumentSnapshot;
    final accountDoc = results[1] as DocumentSnapshot;
    return (info: infoDoc, account: accountDoc);
  }

  @override
  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    DocumentSnapshot? lastDoc,
  }) async {
    return await repository.getPosts(
        limit: limit,
        userId: userId,
        lastPostDoc: lastDoc
    );
  }

  @override
  Future<QuerySnapshot> getVideos({
    required String userId,
    required DocumentSnapshot? lastDoc,
    required int limit,
  }) async {
    return await repository.getPosts(
        limit: limit,
        userId: userId,
        postType: 'video',
        lastPostDoc: lastDoc
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountData(String userId) async {
    final doc = await repository.getDoc(
        docId: userId, collectionPath: 'accounts'
    );
    return await _userAccountService.getAccountMap(userDoc: doc);
  }

  @override
  Future<({int? comments, int? likes})> getPostCounts(String postId) async {
    final postRef = repository.getDocRef(
        docId: postId, collectionPath: 'posts');
    final results = await Future.wait([
      repository.getCount(docRef: postRef, collectionPath: 'likesList'),
      repository.getCount(docRef: postRef, collectionPath: 'commentsList')
    ]);
    return (likes: results[0].count, comments: results[1].count);
  }

  @override
  Future<String> uploadImage({
    required String imageType,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    return repository.uploadImage(
        imageType: imageType,
        postModel: postModel,
        collectionPath: collectionPath,
        currentUid: sessionService.currentUid
    );
  }

  @override
  Future<void> sendFriendRequest(String userId, MyModel friendInfo) async {
    await repository.setSubDoc(
      supDocId: userId,
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      data: friendInfo.toJson(),
      subDocId: friendInfo.myId,
    );
  }

  @override
  Future<void> deleteFriendRequest(String userId) async {
    await repository.deleteSubDoc(
      supDoc: userId,
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      subDoc: sessionService.currentUid,

    );
  }

  @override
  Future<void> deleteFriendship(String userId) async {
    await Future.wait([
      repository.deleteSubDoc(
          subDoc: userId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          supDoc: sessionService.currentUid
      ),
      repository.deleteSubDoc(
          supDoc: userId,
          supCollectionPath: 'users',
          subCollectionPath: 'friends',
          subDoc: sessionService.currentUid
      ),
    ]);
  }

  @override
  Future<void> addFriend(String docId, MyModel friendInfo) async {
    await repository.setSubDoc(
        subDocId: docId,
        supCollectionPath: 'users',
        supDocId: friendInfo.myId,
        subCollectionPath: 'friends',
        data: friendInfo.toJson()
    );
  }

  @override
  Future<List<MyModel>> getFriends(String userId) async {
    final snapshot = await repository.getSubCollection(
        docId: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );

    final List<MyModel> friends = [];
    for (final doc in snapshot.docs) {
      final user = await _userAccountService.getUserModelData(id: doc.id);
      friends.add(user);
    }
    return friends;
  }

  @override
  Future<bool> checkRequestExists(String userId) async {
    final doc = await repository.getSubDoc(
        subDoc: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'requests',
        supDoc: sessionService.currentUid
    );
    return doc.exists;
  }

  @override
  Future<bool> checkFriendExists(String userId) async {
    final doc = await repository.getSubDoc(
        subDoc: userId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        supDoc: sessionService.currentUid
    );
    return doc.exists;
  }
}