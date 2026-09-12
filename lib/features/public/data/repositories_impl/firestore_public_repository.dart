import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../data_sources/remote/firestore_public_service.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';


class FirestorePublicRepository extends PublicRepository {
  final SessionService _sessionService;
  final FirestorePublicService _repository;

  FirestorePublicRepository({
    required SessionService sessionService,
    required FirestorePublicService repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList() {
    return _repository.getSubCollection(
      supCollectionPath: 'users',
      subCollectionPath: 'friends',
      docId: _sessionService.currentUid,
    );
  }

  @override
  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  }) async {
    return await _repository.getDocumentsWithWhereIn(
      limit: limit,
      postType: 'post',
      lastPostDoc: lastPostDoc,
      friendsUIds: friendsUIds,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedPosts() {
    return _repository.getSubCollection(
        docId: _sessionService.currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts'
    );
  }

  @override
  Future<DocumentSnapshot> getAccountData(String userId) async {
    return await _repository.getSupDoc(
        docId: userId,
        collectionPath: 'accounts'
    );
  }

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    return _repository.getPostCounts(postId);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsForStatus({
    required int limit,
    required DocumentSnapshot? lastStatusDoc
  }) async {
    return await _repository.getQuery(
        limit: limit,
        supCollectionPath: 'users',
        subCollectionPath: 'friends',
        lastStatusDoc: lastStatusDoc,
        docId: _sessionService.currentUid
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses() {
    return _repository.getSubCollection(
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_statuses',
        docId: _sessionService.currentUid
    );
  }

  @override
  Future<QuerySnapshot> getStatusesForUser(String userId) async {
    return await _repository.getStatusesByUser(
      userId: userId,
    );
  }

  @override
  Future<void> addPostToFirestore(PostModel postModel) async {
    await _repository.getRefAndSetDoc(
      isMerge: true,
      docId: postModel.docId,
      collectionPath: 'posts',
      data: postModel.toJson(),
    );
  }

  @override
  Future<void> addStatusToFirestore(PostModel statusModel) async {
    await _repository.getRefAndSetDoc(
      isMerge: true,
      docId: statusModel.docId,
      collectionPath: 'status',
      data: statusModel.toJson(),
    );
  }

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await _repository.deleteSupDoc(collectionPath: 'posts', docId: postId);
  }

  @override
  Future<void> addToDeletedPosts(String postId) async {
    await _repository.setSubDoc(
        data: {},
        subDocId: postId,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_posts',
        supDocId: _sessionService.currentUid
    );
  }

  @override
  Future<void> deleteStatusFromFirestore(String statusId) async {
    await _repository.deleteSupDoc(collectionPath: 'status', docId: statusId);
  }

  @override
  Future<void> addToDeletedStatuses(String statusId) async {
    await _repository.setSubDoc(
        data: {},
        subDocId: statusId,
        supCollectionPath: 'users',
        subCollectionPath: 'deleted_statuses',
        supDocId: _sessionService.currentUid
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc) async {
    return await getAccountMap(userDoc);
  }
}