import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/domain/data_sources/remote/firestore/firestore_service.dart';


class FakeFirestoreService implements FirestoreService {
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> docs = {};

  void stubDoc({
    required String docId,
    required String collectionPath,
    required DocumentSnapshot<Map<String, dynamic>> snapshot,
  }) {
    docs['$collectionPath/$docId'] = snapshot;
  }

  // ===== getDocRef =====
  DocumentReference<Map<String, dynamic>>? docRefToReturn;
  int getDocRefCallCount = 0;
  String? lastGetDocRefDocId;
  String? lastGetDocRefCollectionPath;

  @override
  DocumentReference<Map<String, dynamic>> getDocRef({
    required String? docId,
    required String collectionPath,
  }) {
    getDocRefCallCount++;
    lastGetDocRefDocId = docId;
    lastGetDocRefCollectionPath = collectionPath;
    return docRefToReturn!;
  }

// ===== updateDoc =====
  int updateDocCallCount = 0;
  String? lastUpdateDocDocId;
  String? lastUpdateDocCollectionPath;
  Map<String, dynamic>? lastUpdateDocData;
  Object? updateDocError;

  @override
  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    updateDocCallCount++;
    lastUpdateDocDocId = docId;
    lastUpdateDocCollectionPath = collectionPath;
    lastUpdateDocData = data;
    if (updateDocError != null) throw updateDocError!;
  }

  // ===== getDoc =====
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  }) async {
    final snapshot = docs['$collectionPath/$docId'];
    if (snapshot == null) {
      throw Exception('No stub for $collectionPath/$docId');
    }
    return snapshot;
  }

  // ===== setSupDoc =====
  int setSupDocCallCount = 0;
  String? lastSetSupDocId;
  String? lastSetSupCollectionPath;
  Map<String, dynamic>? lastSetSupData;
  bool? lastSetSupIsMerge;
  Object? setSupDocError;

  @override
  Future<void> setSupDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    setSupDocCallCount++;
    lastSetSupDocId = docId;
    lastSetSupCollectionPath = collectionPath;
    lastSetSupData = data;
    lastSetSupIsMerge = isMerge;
    if (setSupDocError != null) throw setSupDocError!;
  }

  // ===== setSubDoc =====
  int setSubDocCallCount = 0;
  String? lastSetSubSupDocId;
  String? lastSetSubSubDocId;
  String? lastSetSubSupCollectionPath;
  String? lastSetSubSubCollectionPath;
  Map<String, dynamic>? lastSetSubData;
  Object? setSubDocError;

  @override
  Future<void> setSubDoc({
    required String? supDocId,
    required String? subDocId,
    required String supCollectionPath,
    required String subCollectionPath,
    required Map<String, dynamic> data,
  }) async {
    setSubDocCallCount++;
    lastSetSubSupDocId = supDocId;
    lastSetSubSubDocId = subDocId;
    lastSetSubSupCollectionPath = supCollectionPath;
    lastSetSubSubCollectionPath = subCollectionPath;
    lastSetSubData = data;
    if (setSubDocError != null) throw setSubDocError!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeFirestoreService.${invocation.memberName} not stubbed',
      );
}