import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/data_sources/public_data_source.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin_impl.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class PublicRepositoryImpl with BaseLikeMixinImpl implements PublicRepository {
  final PublicDataSource _dataSource;
  final SessionService _sessionService;
  static const _deletedPosts = 'deleted_posts';
  static const _deletedStatuses = 'deleted_statuses';

  PublicRepositoryImpl({
    required PublicDataSource dataSource,
    required SessionService sessionService
  })
      : _dataSource = dataSource,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => AppStrings.likesList;

  @override
  PublicDataSource get dataSource => _dataSource;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList() {
    return dataSource.getSubCollection(
      docId: sessionService.currentUid,
      supCollectionPath: AppStrings.users,
      subCollectionPath: AppStrings.friends
    );
  }

  @override
  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  }) async {
    return await dataSource.getDocumentsWithWhereIn(
      limit: limit,
      lastPostDoc: lastPostDoc,
      friendsUIds: friendsUIds,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedPosts() {
    return dataSource.getSubCollection(
      subCollectionPath: _deletedPosts,
      docId: sessionService.currentUid,
      supCollectionPath: AppStrings.users,
    );
  }

  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    return await dataSource.getDoc(
        docId: userId,
        collectionPath: AppStrings.accounts
    );
  }

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(String postId) async {
    return dataSource.getPostCounts(postId);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsForStatus({
    required int limit,
    required DocumentSnapshot? lastStatusDoc
  }) async {
    return await dataSource.getQuery(
        limit: limit,
        lastStatusDoc: lastStatusDoc,
        docId: sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: AppStrings.friends
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses() {
    return dataSource.getSubCollection(
        docId: sessionService.currentUid,
        supCollectionPath: AppStrings.users,
        subCollectionPath: _deletedStatuses
    );
  }

  @override
  Future<QuerySnapshot> getStatusesForUser(String userId) async {
    return await dataSource.getStatusesByUser(
      userId: userId,
    );
  }

  @override
  Future<void> addPostToFirestore(PostModel postModel) async {
    await dataSource.getRefAndSetDoc(
      isMerge: true,
      docId: postModel.myDocId,
      data: postModel.toJson(),
      collectionPath: AppStrings.posts
    );
  }

  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    await dataSource.getRefAndSetDoc(
      isMerge: true,
      docId: statusModel.myDocId,
      data: statusModel.toJson(),
      collectionPath: AppStrings.status
    );
  }

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await dataSource.deleteSupDoc(collectionPath: AppStrings.posts, docId: postId);
  }

  @override
  Future<void> addToDeletedPosts(String postId) async {
    await dataSource.setSubDoc(
        data: {},
        subDocId: postId,
        subCollectionPath: _deletedPosts,
        supCollectionPath: AppStrings.users,
        supDocId: sessionService.currentUid
    );
  }

  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    await dataSource.deleteSupDoc(collectionPath: AppStrings.status, docId: statusId);
  }

  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    await dataSource.setSubDoc(
        data: {},
        subDocId: statusId,
        supCollectionPath: AppStrings.users,
        subCollectionPath: _deletedStatuses,
        supDocId: sessionService.currentUid
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc) async {
    return await getAccountMap(userDoc);
  }
}