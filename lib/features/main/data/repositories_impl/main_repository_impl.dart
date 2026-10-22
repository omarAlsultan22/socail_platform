import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/main_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/features/main/domain/repositories/main_repository.dart';


class MainRepositoryImpl implements MainRepository{
  final MainDataSource _dataSource;
  final SessionService _sessionService;

  MainRepositoryImpl({
    required MainDataSource dataSource,
    required SessionService sessionService
  }): _dataSource = dataSource,
  _sessionService = sessionService;

  @override
  Future<QuerySnapshot> getFriendsList({required String uId}) async {
    return await _dataSource.getSubCollection(
        docId: uId,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );
  }

  @override
  Future<QuerySnapshot> getAllUsersExceptCurrent({required String uId}) async {
    return await _dataSource.getAllUsersExceptCurrent(uId: uId);
  }

  @override
  List<MyModel> convertUsersToModels(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => MyModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuerySnapshot> getUnreadNotifications() async {
    return await _dataSource.getUnreadNotifications();
  }

  @override
  Stream<QuerySnapshot> getNotificationsStream() {
    return _dataSource.getNotificationsStream();
  }

  @override
  Future<QuerySnapshot> getFriendRequests() async {
    return await _dataSource.getSubCollection(
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      docId: _sessionService.currentUid,

    );
  }

  @override
  Stream<QuerySnapshot> getFriendRequestsStream() {
    return _dataSource.getSubCollectionStream(
      supCollectionPath: 'users',
      subCollectionPath: 'requests',
      docId: _sessionService.currentUid,
    );
  }

  @override
  Future<QuerySnapshot> getAllMessages() async {
    return await _dataSource.getSupCollection(collectionPath: 'messages');
  }

  @override
  Future<QuerySnapshot> getUnreadConversations(String messageDocId) async {
    return await _dataSource.getUnreadConversations(
      messageDocId: messageDocId,
    );
  }

  @override
  Stream<QuerySnapshot> getUnreadConversationsStream(String messageDocId) {
    return _dataSource.getUnreadConversationsStream(
      messageDocId: messageDocId,
    );
  }
}