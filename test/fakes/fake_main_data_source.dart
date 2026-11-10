import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/main/domain/data_sources/main_data_source.dart';


class FakeMainDataSource implements MainDataSource {
  // ===== getSubCollection =====
  QuerySnapshot<Map<String, dynamic>>? subCollectionResult;
  int getSubCollectionCallCount = 0;
  String? lastSubDocId;
  String? lastSubSupCollectionPath;
  String? lastSubSubCollectionPath;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    getSubCollectionCallCount++;
    lastSubDocId = docId;
    lastSubSupCollectionPath = supCollectionPath;
    lastSubSubCollectionPath = subCollectionPath;
    return subCollectionResult!;
  }

  // ===== getAllUsersExceptCurrent =====
  QuerySnapshot<Map<String, dynamic>>? allUsersExceptCurrentResult;
  int getAllUsersExceptCurrentCallCount = 0;
  String? lastAllUsersUid;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptCurrent({
    required String uId,
  }) async {
    getAllUsersExceptCurrentCallCount++;
    lastAllUsersUid = uId;
    return allUsersExceptCurrentResult!;
  }

  // ===== getUnreadNotifications =====
  QuerySnapshot<Map<String, dynamic>>? unreadNotificationsResult;
  int getUnreadNotificationsCallCount = 0;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications() async {
    getUnreadNotificationsCallCount++;
    return unreadNotificationsResult!;
  }

  // ===== getNotificationsStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? notificationsStream;
  int getNotificationsStreamCallCount = 0;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream() {
    getNotificationsStreamCallCount++;
    return notificationsStream!;
  }

  // ===== getSubCollectionStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? subCollectionStream;
  int getSubCollectionStreamCallCount = 0;
  String? lastSubStreamDocId;
  String? lastSubStreamSupCollectionPath;
  String? lastSubStreamSubCollectionPath;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getSubCollectionStream({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    getSubCollectionStreamCallCount++;
    lastSubStreamDocId = docId;
    lastSubStreamSupCollectionPath = supCollectionPath;
    lastSubStreamSubCollectionPath = subCollectionPath;
    return subCollectionStream!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeMainDataSource.${invocation.memberName} not stubbed',
      );
}