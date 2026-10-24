import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/data_sources/profile_data_source.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin_impl.dart';


class ProfileRepositoryImpl with BaseLikeMixinImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  ProfileRepositoryImpl({
    required ProfileDataSource dataSource,
    required SessionService sessionService,
    required IUserAccountService userAccountService
  })
      : _dataSource = dataSource,
        _sessionService = sessionService,
        _userAccountService = userAccountService;

  @override
  String get likeCollectionPath => AppStrings.likesList;

  @override
  ProfileDataSource get dataSource => _dataSource;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<({DocumentSnapshot? info, DocumentSnapshot? account})> getProfileInfo(
      String uId) async {
    final results = await Future.wait([
      dataSource.getDoc(docId: uId, collectionPath: AppStrings.info),
      dataSource.getDoc(docId: uId, collectionPath: AppStrings.accounts),
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
    return await dataSource.getPosts(
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
    return await dataSource.getPosts(
        limit: limit,
        userId: userId,
        lastPostDoc: lastDoc,
        postType: AppStrings.video
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountData(String userId) async {
    final doc = await dataSource.getDoc(
        docId: userId, collectionPath: AppStrings.accounts
    );
    return await _userAccountService.getAccountMap(userDoc: doc);
  }

  @override
  Future<({int? comments, int? likes})> getPostCounts(String postId) async {
    final postRef = dataSource.getDocRef(
        docId: postId, collectionPath: AppStrings.posts);
    final results = await Future.wait([
      dataSource.getCount(docRef: postRef, collectionPath: AppStrings.likesList),
      dataSource.getCount(docRef: postRef, collectionPath: AppStrings.commentsList)
    ]);
    return (likes: results[0].count, comments: results[1].count);
  }

  @override
  Future<String> uploadImage({
    required String imageType,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    return dataSource.uploadImage(
        imageType: imageType,
        postModel: postModel,
        collectionPath: collectionPath,
        currentUid: sessionService.currentUid
    );
  }

  @override
  Future<void> sendFriendRequest(String userId, MyModel friendInfo) async {
    await dataSource.setSubDoc(
      supDocId: userId,
      subDocId: friendInfo.myId,
      data: friendInfo.toJson(),
      supCollectionPath: AppStrings.users,
      subCollectionPath: AppStrings.requests
    );
  }

  @override
  Future<void> deleteFriendRequest(String userId) async {
    await dataSource.deleteSubDoc(
      supDoc: userId,
      subDoc: sessionService.currentUid,
      supCollectionPath: AppStrings.users,
      subCollectionPath: AppStrings.requests

    );
  }

  @override
  Future<void> deleteFriendship(String userId) async {
    await Future.wait([
      dataSource.deleteSubDoc(
          subDoc: userId,
          supDoc: sessionService.currentUid,
          supCollectionPath: AppStrings.users,
          subCollectionPath: AppStrings.friends
      ),
      dataSource.deleteSubDoc(
          supDoc: userId,
          subDoc: sessionService.currentUid,
          supCollectionPath: AppStrings.users,
          subCollectionPath: AppStrings.friends
      ),
    ]);
  }

  @override
  Future<void> addFriend(String docId, MyModel friendInfo) async {
    await dataSource.setSubDoc(
        subDocId: docId,
        data: friendInfo.toJson(),
        supDocId: friendInfo.myId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );
  }

  @override
  Future<List<MyModel>> getFriends(String userId) async {
    final snapshot = await dataSource.getSubCollection(
        docId: userId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
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
    final doc = await dataSource.getSubDoc(
        subDoc: userId,
        supDoc: sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.requests
    );
    return doc.exists;
  }

  @override
  Future<bool> checkFriendExists(String userId) async {
    final doc = await dataSource.getSubDoc(
        subDoc: userId,
        supDoc: sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );
    return doc.exists;
  }
}