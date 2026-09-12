import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_sources/remote/firestore_main_service.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/features/main/domain/repositories/main_repository.dart';


class FirestoreMainRepository implements MainRepository{
  final SessionService _sessionService;
  final FirestoreMainService _repository;

  FirestoreMainRepository({
    required SessionService sessionService,
    required FirestoreMainService repository
  }): _repository = repository,
  _sessionService = sessionService;

  @override
  Future<QuerySnapshot> getFriendsList({required String uId}) async {
    return await _repository.getSubCollection(
        docId: uId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );
  }

  @override
  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId}) async {
    return await _repository.getAllUsersExceptCurrent(uId: uId);
  }

  @override
  List<UserModel> convertUsersToModels(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuerySnapshot> getUnreadNotifications() async {
    return await _repository.getUnreadNotifications();
  }

  @override
  Stream<QuerySnapshot> getNotificationsStream() {
    return _repository.getNotificationsStream();
  }

  @override
  Future<QuerySnapshot> getFriendRequests() async {
    return await _repository.getSubCollection(
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      docId: _sessionService.currentUid,

    );
  }

  @override
  Stream<QuerySnapshot> getFriendRequestsStream() {
    return _repository.getSubCollectionStream(
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      docId: _sessionService.currentUid,
    );
  }

  @override
  Future<QuerySnapshot> getAllMessages() async {
    return await _repository.getSupCollection(collectionPath: 'messages');
  }

  @override
  Future<QuerySnapshot> getUnreadConversations(String messageDocId) async {
    return await _repository.getUnreadConversations(
      messageDocId: messageDocId,
    );
  }

  @override
  Stream<QuerySnapshot> getUnreadConversationsStream(String messageDocId) {
    return _repository.getUnreadConversationsStream(
      messageDocId: messageDocId,
    );
  }
}