import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/public_data_source.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin_impl.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class PublicRepositoryImpl with BaseLikeMixinImpl implements PublicRepository {
  final PublicDataSource _dataSource;
  final SessionService _sessionService;

  PublicRepositoryImpl({
    required PublicDataSource dataSource,
    required SessionService sessionService
  })
      : _dataSource = dataSource,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => 'likesList';

  @override
  PublicDataSource get dataSource => _dataSource;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList() {
    return dataSource.getSubCollection(
      supCollectionPath: 'users',
      subCollectionPath: 'friends',
      docId: sessionService.currentUid,
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
        docId: sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts'
    );
  }

  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    return await dataSource.getDoc(
        docId: userId,
        collectionPath: 'accounts'
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
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        lastStatusDoc: lastStatusDoc,
        docId: sessionService.currentUid
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses() {
    return dataSource.getSubCollection(
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_statuses',
        docId: sessionService.currentUid
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
      collectionPath: 'posts',
      data: postModel.toJson(),
    );
  }

  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    await dataSource.getRefAndSetDoc(
      isMerge: true,
      docId: statusModel.myDocId,
      collectionPath: 'status',
      data: statusModel.toJson(),
    );
  }

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await dataSource.deleteSupDoc(collectionPath: 'posts', docId: postId);
  }

  @override
  Future<void> addToDeletedPosts(String postId) async {
    await dataSource.setSubDoc(
        data: {},
        subDocId: postId,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts',
        supDocId: sessionService.currentUid
    );
  }

  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    await dataSource.deleteSupDoc(collectionPath: 'status', docId: statusId);
  }

  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    await dataSource.setSubDoc(
        data: {},
        subDocId: statusId,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_statuses',
        supDocId: sessionService.currentUid
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc) async {
    return await getAccountMap(userDoc);
  }
}