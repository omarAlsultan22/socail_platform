import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../data_sources/remote/firestore_public_service.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/presentation/mixins/base_like_mixin.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class FirestorePublicRepository with BaseLikeMixin implements PublicRepository {
  final SessionService _sessionService;
  final FirestorePublicService _repository;

  FirestorePublicRepository({
    required SessionService sessionService,
    required FirestorePublicService repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => throw UnimplementedError();

  @override
  FirestorePublicService get repository => _repository;

  @override
  SessionService get sessionService => _sessionService;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList() {
    return repository.getSubCollection(
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
    return await repository.getDocumentsWithWhereIn(
      limit: limit,
      lastPostDoc: lastPostDoc,
      friendsUIds: friendsUIds,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedPosts() {
    return repository.getSubCollection(
        docId: sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts'
    );
  }

  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    return await repository.getDoc(
        docId: userId,
        collectionPath: 'accounts'
    );
  }

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(String postId) async {
    return repository.getPostCounts(postId);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsForStatus({
    required int limit,
    required DocumentSnapshot? lastStatusDoc
  }) async {
    return await repository.getQuery(
        limit: limit,
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        lastStatusDoc: lastStatusDoc,
        docId: sessionService.currentUid
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses() {
    return repository.getSubCollection(
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_statuses',
        docId: sessionService.currentUid
    );
  }

  @override
  Future<QuerySnapshot> getStatusesForUser(String userId) async {
    return await repository.getStatusesByUser(
      userId: userId,
    );
  }

  @override
  Future<void> addPostToFirestore(PostModel postModel) async {
    await repository.getRefAndSetDoc(
      isMerge: true,
      docId: postModel.myDocId,
      collectionPath: 'posts',
      data: postModel.toJson(),
    );
  }

  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    await repository.getRefAndSetDoc(
      isMerge: true,
      docId: statusModel.myDocId,
      collectionPath: 'status',
      data: statusModel.toJson(),
    );
  }

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await repository.deleteSupDoc(collectionPath: 'posts', docId: postId);
  }

  @override
  Future<void> addToDeletedPosts(String postId) async {
    await repository.setSubDoc(
        data: {},
        subDocId: postId,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts',
        supDocId: sessionService.currentUid
    );
  }

  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    await repository.deleteSupDoc(collectionPath: 'status', docId: statusId);
  }

  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    await repository.setSubDoc(
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